// Lot 7 – Carte de la tournée de livraison (control add-in "GNC Delivery Map").
// Reçoit la tournée de BC (LoadRound), calcule l'ordre des arrêts : groupes de priorité
// (Very Urgent, puis Urgent, puis Normal), plus proche voisin puis amélioration 2-opt dans chaque groupe.
// Distances : vol d'oiseau (formule de Haversine) x 1,3 pour approcher la distance par la route.
var GNCDeliveryMap = (function () {
  var PRIO_ORDER = ["Very Urgent", "Urgent", "Normal"];
  var ROAD_FACTOR = 1.3;
  var root, map, layers, data, route = [], noCoords = [], showEntry = true, highlighted = null, savedOrder = false;

  function invoke(name, args) { Microsoft.Dynamics.NAV.InvokeExtensibilityMethod(name, args); }

  // ---------- Distances et optimisation ----------
  function km(a, b) {
    var R = 6371, toRad = Math.PI / 180;
    var dLat = (b.lat - a.lat) * toRad, dLng = (b.lng - a.lng) * toRad;
    var h = Math.sin(dLat / 2) * Math.sin(dLat / 2) + Math.cos(a.lat * toRad) * Math.cos(b.lat * toRad) * Math.sin(dLng / 2) * Math.sin(dLng / 2);
    return 2 * R * Math.asin(Math.sqrt(h)) * ROAD_FACTOR;
  }
  function routeKm(seq) {
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
    var t = data.startMinutes, prev = data.warehouse, rows = [];
    seq.forEach(function (s) { t += km(prev, s) / data.speed * 60; rows.push({ s: s, eta: t }); t += serviceMin(s); prev = s; });
    if (seq.length) t += km(prev, data.warehouse) / data.speed * 60;
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
      '<button type="button" class="gnc-btn" id="gEntry">Hide order-entry route</button></div>' +
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

    if (typeof L !== "undefined") {
      map = L.map("gncMap", { zoomControl: true }).setView([24.7136, 46.6753], 11); // Riyad
      L.tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", {
        maxZoom: 18, attribution: "&copy; OpenStreetMap contributors"
      }).addTo(map);
      layers = L.layerGroup().addTo(map);
    } else {
      document.getElementById("gncMap").appendChild(el("div", "gnc-empty", "The map could not be loaded (no internet access to OpenStreetMap). The stop sequence still works."));
    }
  }

  // ---------- Données reçues de BC ----------
  function load(d) {
    data = d;
    data.speed = data.speed || 28;
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
    if (map && (withCoords.length || data.warehouse)) {
      var pts = withCoords.map(function (s) { return [s.lat, s.lng]; }).concat([[data.warehouse.lat, data.warehouse.lng]]);
      map.fitBounds(pts, { padding: [40, 40] });
      setTimeout(function () { map.invalidateSize(); }, 200);
    }
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
    if (noCoords.length) note.appendChild(el("div", "gnc-note", noCoords.length + " order(s) without GPS position: fill in Latitude and Longitude on the customer card."));
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

  function renderMap(entry) {
    if (!map) return;
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
