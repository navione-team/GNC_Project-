// Lot 7 – Carte de la tournée de livraison (control add-in "GNC Delivery Map").
// Reçoit la tournée de BC (LoadRound), calcule l'ordre des arrêts : groupes de priorité
// (Very Urgent, puis Urgent, puis Normal), plus proche voisin puis amélioration 2-opt dans chaque groupe.
// Distances pour choisir l'ordre : vol d'oiseau (formule de Haversine) x 1,3.
// Avec une clé Google Maps (GNC Sales Setup) : carte Google, distances et durées par la route (Directions),
// recherche des positions manquantes (Geocoder). Sans clé ou si la clé est refusée : carte OpenStreetMap et estimation.
var GNCDeliveryMap = (function () {
  var PRIO_ORDER = ["Very Urgent", "Urgent", "Normal"];
  var ROAD_FACTOR = 1.3;
  var MAX_GOOGLE_STOPS = 25, MAX_LINK_STOPS = 9;
  var root, map, layers, data, route = [], noCoords = [], showEntry = true, highlighted = null, savedOrder = false;
  var engine = null, gmap, directions, geocoder, gOverlays = [], roads = {}, mapNote = "", geocoding = false;

  // Trajet par la route déjà reçu de Google pour cette suite d'arrêts (sinon undefined)
  function seqKey(seq) { return seq.map(function (s) { return s.orderNo; }).join(","); }
  function road(seq) { var r = roads[seqKey(seq)]; return r && r.km !== undefined ? r : undefined; }

  function invoke(name, args) { Microsoft.Dynamics.NAV.InvokeExtensibilityMethod(name, args); }

  // ---------- Distances et optimisation ----------
  function km(a, b) {
    var R = 6371, toRad = Math.PI / 180;
    var dLat = (b.lat - a.lat) * toRad, dLng = (b.lng - a.lng) * toRad;
    var h = Math.sin(dLat / 2) * Math.sin(dLat / 2) + Math.cos(a.lat * toRad) * Math.cos(b.lat * toRad) * Math.sin(dLng / 2) * Math.sin(dLng / 2);
    return 2 * R * Math.asin(Math.sqrt(h)) * ROAD_FACTOR;
  }
  function routeKm(seq) {
    var r = road(seq);
    if (r) return r.km;
    var total = 0, prev = data.warehouse;
    seq.forEach(function (s) { total += km(prev, s); prev = s; });
    return seq.length ? total + km(prev, data.warehouse) : 0;
  }
  function segKm(seg, from) {
    var total = 0, prev = from;
    seg.forEach(function (s) { total += km(prev, s); prev = s; });
    return total;
  }
  function twoOpt(seg, from) {
    if (seg.length < 3) return seg;
    var best = seg.slice(), improved = true;
    while (improved) {
      improved = false;
      for (var i = 0; i < best.length - 1; i++)
        for (var j = i + 1; j < best.length; j++) {
          var cand = best.slice(0, i).concat(best.slice(i, j + 1).reverse(), best.slice(j + 1));
          if (segKm(cand, from) + 1e-9 < segKm(best, from)) { best = cand; improved = true; }
        }
    }
    return best;
  }
  function optimise(list) {
    var out = [], cur = data.warehouse;
    PRIO_ORDER.forEach(function (p) {
      var group = list.filter(function (s) { return s.priority === p; }), seg = [];
      while (group.length) {
        group.sort(function (a, b) { return km(cur, a) - km(cur, b); });
        cur = group.shift(); seg.push(cur);
      }
      var from = out.length ? out[out.length - 1] : data.warehouse;
      out = out.concat(twoOpt(seg, from));
      if (out.length) cur = out[out.length - 1];
    });
    return out;
  }

  // ---------- Horaires ----------
  function serviceMin(s) { return 8 + (s.coldUnits > 0 ? 5 : 0); } // déchargement : 8 min, +5 min si froid
  function schedule(seq) {
    var t = data.startMinutes, prev = data.warehouse, rows = [], r = road(seq);
    seq.forEach(function (s, i) { t += r ? r.legs[i] : km(prev, s) / data.speed * 60; rows.push({ s: s, eta: t }); t += serviceMin(s); prev = s; });
    if (seq.length) t += r ? r.legs[seq.length] : km(prev, data.warehouse) / data.speed * 60;
    return { rows: rows, end: t };
  }
  function hhmm(m) { m = Math.round(m); return String(Math.floor(m / 60) % 24).padStart(2, "0") + ":" + String(m % 60).padStart(2, "0"); }
  function dur(m) { m = Math.round(m); return Math.floor(m / 60) + " h " + String(m % 60).padStart(2, "0"); }
  function num(v) { return (Math.round(v * 10) / 10).toLocaleString(); }

  // ---------- Construction de l'écran ----------
  function el(tag, cls, text) { var e = document.createElement(tag); if (cls) e.className = cls; if (text !== undefined) e.textContent = text; return e; }

  function init(container) {
    root = container;
    root.innerHTML =
      '<div class="gnc-kpis">' +
      '<div class="gnc-kpi"><div class="l">Distance</div><div class="v" id="gK1">–</div><div class="d" id="gK1d"></div></div>' +
      '<div class="gnc-kpi"><div class="l">Duration</div><div class="v" id="gK2">–</div><div class="d" id="gK2d"></div></div>' +
      '<div class="gnc-kpi"><div class="l">Stops</div><div class="v" id="gK3">–</div><div class="d" id="gK3d"></div></div>' +
      '<div class="gnc-kpi"><div class="l">Vehicle load</div><div class="v" id="gK4">–</div><div class="d" id="gK4d"></div></div>' +
      '</div>' +
      '<div class="gnc-main">' +
      '<div class="gnc-panel"><h3>Stop sequence</h3>' +
      '<div class="gnc-tools"><button type="button" class="gnc-btn primary" id="gReopt">Re-optimise</button>' +
      '<button type="button" class="gnc-btn" id="gSave">Save sequence</button>' +
      '<button type="button" class="gnc-btn" id="gEntry">Hide order-entry route</button>' +
      '<button type="button" class="gnc-btn" id="gNav">Open route in Google Maps</button>' +
      '<button type="button" class="gnc-btn" id="gGeo">Find missing positions</button></div>' +
      '<div id="gNote"></div><ol class="gnc-stops" id="gStops"></ol></div>' +
      '<div class="gnc-mapwrap"><div id="gncMap"></div><div class="gnc-constraints" id="gCons"></div>' +
      '<div class="gnc-legend"><span><i></i>Optimised round <b id="gLgOpt"></b></span><span><i class="entry"></i>Order-entry sequence <b id="gLgEntry"></b></span><span><i class="c"></i>Cold chain stop</span></div></div>' +
      '</div>';

    document.getElementById("gReopt").addEventListener("click", function () { route = optimise(route.concat()); savedOrder = false; render(true); });
    document.getElementById("gSave").addEventListener("click", function () {
      invoke("SaveSequence", [route.map(function (s) { return s.orderNo; }).join(",")]);
      savedOrder = true; render(false);
    });
    document.getElementById("gEntry").addEventListener("click", function (e) {
      showEntry = !showEntry;
      e.currentTarget.textContent = showEntry ? "Hide order-entry route" : "Show order-entry route";
      render(false);
    });
    document.getElementById("gNav").addEventListener("click", function () { invoke("OpenUrl", [routeUrl()]); });
    document.getElementById("gGeo").addEventListener("click", findMissingPositions);
  }

  // ---------- Choix de la carte ----------
  function setupLeaflet() {
    var box = document.getElementById("gncMap");
    box.innerHTML = "";
    if (typeof L !== "undefined") {
      map = L.map("gncMap", { zoomControl: true }).setView([24.7136, 46.6753], 11); // Riyad
      L.tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", {
        maxZoom: 18, attribution: "&copy; OpenStreetMap contributors"
      }).addTo(map);
      layers = L.layerGroup().addTo(map);
      engine = "leaflet";
    } else {
      engine = "none";
      box.appendChild(el("div", "gnc-empty", "The map could not be loaded (no internet access to OpenStreetMap). The stop sequence still works."));
    }
  }

  // Clé refusée ou Google inaccessible : on revient à OpenStreetMap
  function googleFailed(message) {
    if (engine === "leaflet") return;
    gOverlays.forEach(function (o) { o.setMap(null); });
    gOverlays = []; gmap = null; directions = null; geocoder = null; roads = {};
    mapNote = message;
    setupLeaflet();
    if (data) { render(true); fitMap(); }
  }

  function setupGoogle(key) {
    engine = "loading";
    window.gm_authFailure = function () { googleFailed("Google Maps refused the API key: OpenStreetMap is shown instead. Check the key in GNC Sales Setup."); };
    window.GNCGoogleReady = function () {
      gmap = new google.maps.Map(document.getElementById("gncMap"), { center: { lat: 24.7136, lng: 46.6753 }, zoom: 11 });
      directions = new google.maps.DirectionsService();
      geocoder = new google.maps.Geocoder();
      engine = "google";
      render(true);
      fitMap();
    };
    var script = document.createElement("script");
    script.src = "https://maps.googleapis.com/maps/api/js?key=" + encodeURIComponent(key) + "&callback=GNCGoogleReady";
    script.async = true;
    script.onerror = function () { googleFailed("Google Maps could not be loaded: OpenStreetMap is shown instead."); };
    document.head.appendChild(script);
  }

  function fitMap() {
    if (!data) return;
    var pts = route.map(function (s) { return { lat: s.lat, lng: s.lng }; }).concat([{ lat: data.warehouse.lat, lng: data.warehouse.lng }]);
    if (engine === "leaflet") {
      map.fitBounds(pts.map(function (p) { return [p.lat, p.lng]; }), { padding: [40, 40] });
      setTimeout(function () { map.invalidateSize(); }, 200);
    } else if (engine === "google") {
      var bounds = new google.maps.LatLngBounds();
      pts.forEach(function (p) { bounds.extend(p); });
      gmap.fitBounds(bounds, 40);
    }
  }

  // ---------- Navigation (liens Google Maps, sans clé) ----------
  function pos(p) { return p.lat + "," + p.lng; }
  function routeUrl() {
    var depot = pos(data.warehouse);
    return "https://www.google.com/maps/dir/?api=1&travelmode=driving&origin=" + depot + "&destination=" + depot +
      "&waypoints=" + encodeURIComponent(route.map(pos).join("|"));
  }
  function stopUrl(s) { return "https://www.google.com/maps/dir/?api=1&travelmode=driving&destination=" + pos(s); }

  // ---------- Recherche des positions manquantes (Google Geocoder) ----------
  function findMissingPositions() {
    if (!geocoder || geocoding) return;
    var todo = noCoords.slice(), found = 0, missed = [];
    geocoding = true;
    function next() {
      if (!todo.length) {
        geocoding = false;
        mapNote = found + " position(s) found: check each stop on the map." + (missed.length ? " Not found: " + missed.join(", ") + "." : "");
        if (found) invoke("PositionsSaved", []); else render(false);
        return;
      }
      var s = todo.shift();
      geocoder.geocode({ address: [s.address, s.city, s.country].filter(Boolean).join(", ") }, function (res, status) {
        if (status === "OK" && res.length) {
          var p = res[0].geometry.location;
          invoke("SavePosition", [s.orderNo, String(p.lat()), String(p.lng())]);
          found++;
        } else {
          missed.push(s.customer);
        }
        setTimeout(next, 250);
      });
    }
    next();
  }

  // ---------- Données reçues de BC ----------
  function load(d) {
    data = d;
    data.speed = data.speed || 28;
    roads = {};
    if (engine === null) {
      if (data.googleKey) setupGoogle(data.googleKey); else setupLeaflet();
    }
    var stops = (data.stops || []).map(function (s) { s.lat = Number(s.lat); s.lng = Number(s.lng); return s; });
    var withCoords = stops.filter(function (s) { return s.lat !== 0 || s.lng !== 0; });
    noCoords = stops.filter(function (s) { return s.lat === 0 && s.lng === 0; });
    // Ordre déjà enregistré (n° d'arrêt sur toutes les commandes) : on le garde, sinon on optimise
    var allSaved = withCoords.length > 0 && withCoords.every(function (s) { return s.stopNo > 0; });
    if (allSaved) {
      route = withCoords.slice().sort(function (a, b) { return a.stopNo - b.stopNo; });
      savedOrder = true;
    } else {
      route = optimise(withCoords);
      savedOrder = false;
    }
    highlighted = null;
    render(true);
    fitMap();
  }

  function render(fit) {
    if (!data) return;
    var sch = schedule(route);
    var entry = route.slice().sort(function (a, b) { return a.orderNo < b.orderNo ? -1 : 1; });
    var optKm = routeKm(route), entryKm = routeKm(entry), entrySch = schedule(entry);
    var units = route.reduce(function (a, s) { return a + s.units; }, 0) + noCoords.reduce(function (a, s) { return a + s.units; }, 0);
    var coldUnits = route.reduce(function (a, s) { return a + s.coldUnits; }, 0);
    var load = data.capacity > 0 ? Math.round(units / data.capacity * 100) : null;

    // Indicateurs
    setText("gK1", route.length ? num(optKm) + " km" : "–");
    setText("gK1d", entryKm - optKm > 0.5 ? "−" + num(entryKm - optKm) + " km (−" + Math.round((entryKm - optKm) / entryKm * 100) + "%)" : "");
    setText("gK2", route.length ? dur(sch.end - data.startMinutes) : "–");
    setText("gK2d", entrySch.end - sch.end > 1 ? "−" + Math.round(entrySch.end - sch.end) + " min" : "");
    setText("gK3", String(route.length + noCoords.length));
    setText("gK3d", num(units) + " units");
    setText("gK4", load === null ? "–" : load + "%");
    var k4d = document.getElementById("gK4d");
    k4d.textContent = coldUnits > 0 ? num(coldUnits) + " cold units" : (load === null ? "capacity not set" : "");
    k4d.className = "d" + ((load !== null && load > 100) || (coldUnits > 0 && !data.refrigerated) ? " bad" : "");
    setText("gLgOpt", "· " + num(optKm) + " km");
    setText("gLgEntry", "· " + num(entryKm) + " km");

    // Message
    var note = document.getElementById("gNote");
    note.innerHTML = "";
    if (!route.length && !noCoords.length) note.appendChild(el("div", "gnc-note", "No released order to deliver for this driver and date."));
    if (mapNote) note.appendChild(el("div", "gnc-note", mapNote));
    if (noCoords.length) note.appendChild(el("div", "gnc-note", noCoords.length + " order(s) without GPS position: choose Find missing positions, or fill in Latitude and Longitude on the customer card."));
    if (route.length) {
      var rr = roads[seqKey(route)];
      if (rr && rr.failed) note.appendChild(el("div", "gnc-note", "Google could not calculate the road route (" + rr.failed + "): estimated distances are shown."));
      else note.appendChild(el("div", "gnc-note", road(route) ? "Distances and times use the Google Maps road route, without live traffic." : "Distances and times are estimates, not road directions."));
    }
    var nav = document.getElementById("gNav");
    nav.disabled = !route.length || route.length > MAX_LINK_STOPS;
    nav.title = route.length > MAX_LINK_STOPS ? "Too many stops for one link: use Navigate on each stop." : "";
    document.getElementById("gGeo").style.display = geocoder && noCoords.length ? "" : "none";
    if (route.length) note.appendChild(el("div", "gnc-note" + (savedOrder ? " ok" : ""), savedOrder ? "This sequence is saved on the orders (Stop No.)." : "Sequence not saved yet: choose Save sequence."));

    // Liste des arrêts
    var ol = document.getElementById("gStops");
    ol.innerHTML = "";
    ol.appendChild(row("S", hhmm(data.startMinutes), "Start, " + data.warehouse.name, data.driverName + " · " + data.vehicle, null, true));
    sch.rows.forEach(function (r, i) { ol.appendChild(row(i + 1, hhmm(r.eta), r.s.customer, r.s.orderNo + " · " + num(r.s.units) + " units · " + (r.s.city || ""), r.s)); });
    if (route.length) ol.appendChild(row("E", hhmm(sch.end), "Return, " + data.warehouse.name, "", null, true));
    noCoords.forEach(function (s) { ol.appendChild(row("?", "--:--", s.customer, s.orderNo + " · no GPS position", s)); });

    renderConstraints(sch, load, coldUnits);
    renderMap(entry);
  }

  function setText(id, t) { document.getElementById(id).textContent = t; }

  function row(n, time, name, meta, s, end) {
    var li = el("li", "gnc-stop" + (s && highlighted === s.orderNo ? " hl" : ""));
    li.appendChild(el("span", "gnc-dot" + (end ? " end" : s && s.coldUnits > 0 ? " cold" : ""), String(n)));
    li.appendChild(el("span", "gnc-time", time));
    var mid = el("span"); mid.appendChild(el("div", "gnc-name", name)); mid.appendChild(el("div", "gnc-meta", meta)); li.appendChild(mid);
    var b = el("span", "gnc-badges");
    if (s) {
      b.appendChild(el("span", "gnc-chip " + s.priority.replace(" ", ""), s.priority));
      if (s.coldUnits > 0) b.appendChild(el("span", "gnc-chip cold", "❄ cold"));
      var open = el("button", "gnc-open", "Open order"); open.type = "button";
      open.addEventListener("click", function (e) { e.stopPropagation(); invoke("OpenOrder", [s.orderNo]); });
      b.appendChild(open);
      if (s.lat !== 0 || s.lng !== 0) {
        var go = el("button", "gnc-open", "Navigate"); go.type = "button";
        go.addEventListener("click", function (e) { e.stopPropagation(); invoke("OpenUrl", [stopUrl(s)]); });
        b.appendChild(go);
      }
      li.addEventListener("click", function () { highlighted = highlighted === s.orderNo ? null : s.orderNo; render(false); });
    }
    li.appendChild(b);
    return li;
  }

  function renderConstraints(sch, load, coldUnits) {
    var prios = route.map(function (s) { return s.priority; });
    var lastVery = prios.lastIndexOf("Very Urgent"), firstNormal = prios.indexOf("Normal");
    var coldRows = sch.rows.filter(function (r) { return r.s.coldUnits > 0; });
    var items = [
      [lastVery === -1 || firstNormal === -1 || lastVery < firstNormal, "Very Urgent orders served first"],
      [coldUnits === 0 || data.refrigerated, "Cold chain items in a refrigerated vehicle"],
      [coldRows.every(function (r) { return r.eta - data.startMinutes <= 140; }), "Cold items delivered within 2 h 20 of loading"],
      [load === null || load <= 100, load === null ? "Vehicle capacity not set (Drivers)" : "Vehicle capacity respected (" + load + "%)"],
      [noCoords.length === 0, "Every order has a GPS position"]
    ];
    var c = document.getElementById("gCons");
    c.innerHTML = "<b>Constraints</b>";
    var ul = el("ul");
    items.forEach(function (it) { ul.appendChild(el("li", it[0] ? "" : "ko", it[1])); });
    c.appendChild(ul);
  }

  function marker(latlng, label, cls, title) {
    return L.marker(latlng, {
      icon: L.divIcon({ className: "", html: '<div class="gnc-marker ' + cls + '">' + label + "</div>", iconSize: [26, 26], iconAnchor: [13, 13] }),
      title: title
    });
  }

  // Demande à Google le trajet par la route d'une suite d'arrêts (une seule fois), puis redessine
  function ensureRoad(seq) {
    var key = seqKey(seq);
    if (!directions || !seq.length || seq.length > MAX_GOOGLE_STOPS || roads[key]) return;
    roads[key] = { pending: true };
    var depot = { lat: data.warehouse.lat, lng: data.warehouse.lng };
    directions.route({
      origin: depot, destination: depot, optimizeWaypoints: false, travelMode: "DRIVING",
      waypoints: seq.map(function (s) { return { location: { lat: s.lat, lng: s.lng }, stopover: true }; })
    }, function (res, status) {
      if (status === "OK") {
        var r = res.routes[0], total = 0, legs = [];
        r.legs.forEach(function (l) { total += l.distance.value; legs.push(l.duration.value / 60); });
        roads[key] = { km: total / 1000, legs: legs, path: r.overview_path };
      } else {
        roads[key] = { failed: status };
      }
      render(false);
    });
  }

  function renderGoogle(entry) {
    gOverlays.forEach(function (o) { o.setMap(null); });
    gOverlays = [];
    var depot = { lat: data.warehouse.lat, lng: data.warehouse.lng };
    function path(seq) {
      var r = road(seq);
      return r ? r.path : [depot].concat(seq.map(function (s) { return { lat: s.lat, lng: s.lng }; }), [depot]);
    }
    function add(o) { o.setMap(gmap); gOverlays.push(o); return o; }
    function pin(position, label, color, title, large) {
      return add(new google.maps.Marker({
        position: position, title: title,
        label: { text: label, color: "#ffffff", fontWeight: "bold", fontSize: "12px" },
        icon: { path: google.maps.SymbolPath.CIRCLE, scale: large ? 16 : 13, fillColor: color, fillOpacity: 1, strokeColor: "#ffffff", strokeWeight: 2 }
      }));
    }
    if (route.length) {
      ensureRoad(route);
      if (showEntry) {
        ensureRoad(entry);
        add(new google.maps.Polyline({
          path: path(entry), strokeOpacity: 0,
          icons: [{ icon: { path: "M 0,-1 0,1", strokeOpacity: 1, strokeColor: "#c9867c", scale: 2 }, offset: "0", repeat: "12px" }]
        }));
      }
      add(new google.maps.Polyline({ path: path(route), strokeColor: "#0e7c6b", strokeWeight: 4 }));
    }
    pin(depot, "S", "#33404d", data.warehouse.name);
    route.forEach(function (s, i) {
      var color = s.coldUnits > 0 ? "#2a7de1" : s.priority === "Very Urgent" ? "#c0392b" : s.priority === "Urgent" ? "#d9822b" : "#0e7c6b";
      var m = pin({ lat: s.lat, lng: s.lng }, String(i + 1), color, (i + 1) + ". " + s.customer + " (" + s.priority + ")", highlighted === s.orderNo);
      m.addListener("click", function () { highlighted = s.orderNo; render(false); });
    });
  }

  function renderMap(entry) {
    if (engine === "google") { renderGoogle(entry); return; }
    if (engine !== "leaflet") return;
    layers.clearLayers();
    var depot = [data.warehouse.lat, data.warehouse.lng];
    function line(seq) { return [depot].concat(seq.map(function (s) { return [s.lat, s.lng]; }), [depot]); }
    if (route.length) {
      if (showEntry) L.polyline(line(entry), { color: "#c9867c", weight: 2, dashArray: "6 6" }).addTo(layers);
      L.polyline(line(route), { color: "#0e7c6b", weight: 4 }).addTo(layers);
    }
    marker(depot, "S", "depot", data.warehouse.name).addTo(layers);
    route.forEach(function (s, i) {
      var cls = (s.coldUnits > 0 ? "cold " : "") + s.priority.replace(" ", "") + (highlighted === s.orderNo ? " hl" : "");
      var m = marker([s.lat, s.lng], String(i + 1), cls, (i + 1) + ". " + s.customer + " (" + s.priority + ")");
      m.on("click", function () { highlighted = s.orderNo; render(false); });
      m.addTo(layers);
    });
  }

  return { init: init, load: load };
})();

// Appelée par BC (procédure LoadRound du control add-in)
function LoadRound(data) { GNCDeliveryMap.load(data); }
