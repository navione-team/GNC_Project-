// Lot 7 – écran du plan de livraison (control add-in "GNC Delivery Plan View"), style « professionnel ».
// BC envoie les données (LoadPlan) ; les filtres et la commande choisie restent dans la page JavaScript.
// Les actions (chauffeur, expédition, ouverture) sont faites par BC, qui renvoie ensuite les données à jour.
var GNCDeliveryPlan = (function () {
  var root, app, data = null, sel = null, fDriver = "", fSum = "", search = "", fStock = "";
  var PRIOS = [["Very Urgent", "crit"], ["Urgent", "warn"], ["Normal", ""]];

  // Icônes (dessinées une seule fois, réutilisées par <use>)
  var SPRITE =
    '<svg width="0" height="0" style="position:absolute" aria-hidden="true">' +
    '<symbol id="dpi-search" viewBox="0 0 24 24"><circle cx="11" cy="11" r="7"></circle><path d="M20 20l-3.5-3.5"></path></symbol>' +
    '<symbol id="dpi-cold" viewBox="0 0 24 24"><path d="M12 2v20M4.5 6.5l15 11M19.5 6.5l-15 11M9 4l3 2 3-2M9 20l3-2 3 2"></path></symbol>' +
    '<symbol id="dpi-gift" viewBox="0 0 24 24"><rect x="3" y="8" width="18" height="13" rx="1"></rect><path d="M12 8v13M3 12h18M12 8c-2-4-6-4-6-1.5S10 8 12 8zM12 8c2-4 6-4 6-1.5S14 8 12 8z"></path></symbol>' +
    '<symbol id="dpi-check" viewBox="0 0 24 24"><path d="M5 12.5l4.5 4.5L19 7.5"></path></symbol>' +
    '<symbol id="dpi-x" viewBox="0 0 24 24"><path d="M6 6l12 12M18 6L6 18"></path></symbol>' +
    '<symbol id="dpi-truck" viewBox="0 0 24 24"><path d="M2 6h11v10H2zM13 10h5l3 3v3h-8"></path><circle cx="6" cy="18" r="1.8"></circle><circle cx="17" cy="18" r="1.8"></circle></symbol>' +
    '<symbol id="dpi-pin" viewBox="0 0 24 24"><path d="M12 21s-7-6.2-7-11.5A7 7 0 0 1 19 9.5C19 14.8 12 21 12 21z"></path><circle cx="12" cy="9.5" r="2.5"></circle></symbol>' +
    '<symbol id="dpi-cal" viewBox="0 0 24 24"><rect x="3" y="5" width="18" height="16" rx="2"></rect><path d="M3 10h18M8 3v4M16 3v4"></path></symbol>' +
    '<symbol id="dpi-route" viewBox="0 0 24 24"><circle cx="6" cy="18" r="2.5"></circle><circle cx="18" cy="6" r="2.5"></circle><path d="M8.5 18H15a3 3 0 0 0 0-6H9a3 3 0 0 1 0-6h6.5"></path></symbol>' +
    '<symbol id="dpi-refresh" viewBox="0 0 24 24"><path d="M20 11a8 8 0 1 0-2.3 5.7M20 4v7h-7"></path></symbol>' +
    "</svg>";

  function ico(name) { return '<svg class="dp-i"><use href="#dpi-' + name + '"></use></svg>'; }
  function act(name, a1, a2) { Microsoft.Dynamics.NAV.InvokeExtensibilityMethod("Action", [name, a1 || "", a2 || ""]); }
  function esc(s) { return String(s === undefined || s === null ? "" : s).replace(/[&<>"']/g, function (c) { return { "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" }[c]; }); }
  function num(v) { return Math.round(Number(v) || 0).toLocaleString(); }
  function drv(code) { var d = null; data.drivers.forEach(function (x) { if (x.code === code) d = x; }); return d; }
  function byNo(no) { var o = null; data.orders.forEach(function (x) { if (x.no === no) o = x; }); return o; }
  function prioCls(p) { return p === "Very Urgent" ? "crit" : p === "Urgent" ? "warn" : ""; }
  function initials(name) { return String(name || "?").split(" ").filter(function (w) { return w; }).map(function (w) { return w.charAt(0); }).slice(0, 2).join("").toUpperCase(); }
  function firstName(name) { return String(name || "").split(" ")[0]; }
  function hasStockIssue(o) { return o.stock === "Partial" || o.stock === "Not Available"; }
  function stockTag(s) {
    if (!s) return '<span class="dp-tag">No stock item</span>';
    return '<span class="dp-tag ' + (s === "Available" ? "ok" : s === "Partial" ? "warn" : "crit") + '">' + esc(s) + "</span>";
  }

  function init(container) {
    root = container;
    root.innerHTML = SPRITE + '<div id="dpApp"><div class="dp-empty">Loading the delivery plan…</div></div>';
    app = document.getElementById("dpApp");
    root.addEventListener("click", function (e) {
      var t = e.target.closest("[data-sum],[data-drv],[data-no],[data-act]");
      if (!t) return;
      if (t.hasAttribute("data-sum")) { fSum = fSum === t.getAttribute("data-sum") ? "" : t.getAttribute("data-sum"); render(); }
      else if (t.hasAttribute("data-drv")) { fDriver = t.getAttribute("data-drv"); render(); }
      else if (t.hasAttribute("data-no")) { sel = t.getAttribute("data-no"); render(); }
      else if (t.tagName !== "SELECT") act(t.getAttribute("data-act"), t.getAttribute("data-a1"));
    });
    root.addEventListener("keydown", function (e) {
      var t = e.target.closest("[data-no]");
      if (t && (e.key === "Enter" || e.key === " ")) { e.preventDefault(); sel = t.getAttribute("data-no"); render(); }
    });
    root.addEventListener("change", function (e) {
      if (e.target.id === "dpAssign") act("setDriver", sel, e.target.value);
      if (e.target.id === "dpStock") { fStock = e.target.value; render(); }
    });
    root.addEventListener("input", function (e) {
      if (e.target.id === "dpSearch") { search = e.target.value; renderTable(); }
    });
  }

  function load(d) {
    data = d;
    data.orders = data.orders || [];
    data.drivers = data.drivers || [];
    if (!byNo(sel)) sel = data.orders.length ? data.orders[0].no : null;
    render();
  }

  // Contrôles avant l'expédition (même logique que la maquette validée)
  function checksFor(o) {
    var d = drv(o.driver);
    return [
      [!!d, d ? "Driver " + d.name + (d.vehicle ? " · " + d.vehicle : "") : "Choose a driver"],
      [o.stock !== "Not Available", o.stock === "Available" ? "All items are in stock" + (data.location ? " at " + data.location : "") : o.stock === "Partial" ? "Partial stock, the available quantity will be shipped" : o.stock ? "No stock for this order" : "No stock item on this order"],
      [!o.cold || (d && d.fridge), o.cold ? (d && d.fridge ? "Cold chain items travel in a refrigerated vehicle" : "Cold chain items need a refrigerated vehicle") : "No cold chain item"],
      [!!o.phone, o.phone ? "Delivery contact " + o.phone : "No phone number for the delivery address"]
    ];
  }

  function render() {
    if (!data) return;
    var orders = data.orders;
    var s = [
      ["all", "To deliver", orders.length, "released orders", "acc"],
      ["very", "Very urgent", orders.filter(function (o) { return o.priority === "Very Urgent"; }).length, "served first", "crit"],
      ["nodrv", "Without driver", orders.filter(function (o) { return !o.driver; }).length, "blocked for shipping", "warn"],
      ["stock", "Stock issues", orders.filter(hasStockIssue).length, "partial or missing", "warn"],
      ["cold", "Cold chain", orders.filter(function (o) { return o.cold; }).length, "refrigerated vehicle", "cold"]
    ];
    var segs = [["", "All"]].concat(data.drivers.map(function (d) { return [d.code, firstName(d.name) || d.code]; }), [["-", "Unassigned"]]);
    app.innerHTML =
      '<div class="dp-wrap">' +
      '<div class="dp-title"><div><div class="dp-crumb">GNC Sales · Warehouse</div><h1>Delivery Plan</h1>' +
      '<div class="dp-sub"><span>' + ico("cal") + esc(data.dateText) + "</span>" + (data.location ? "<span>" + ico("pin") + "Location " + esc(data.location) + "</span>" : "") + "</div></div>" +
      '<div class="dp-actions"><button type="button" class="dp-btn" data-act="refresh">' + ico("refresh") + 'Refresh</button><button type="button" class="dp-btn" data-act="list">List view</button>' +
      '<button type="button" class="dp-btn primary" data-act="round" data-a1="' + esc(sel || "") + '">' + ico("route") + "Delivery round</button></div></div>" +
      '<div class="dp-sum" role="group" aria-label="Summary filters">' + s.map(function (x) {
        return '<button type="button" class="' + (fSum === x[0] ? "on" : "") + '" data-sum="' + x[0] + '" aria-pressed="' + (fSum === x[0]) + '"><span class="l"><span class="dp-dot ' + x[4] + '"></span>' + x[1] + '</span><span class="v">' + x[2] + '</span><span class="s">' + x[3] + "</span></button>";
      }).join("") + "</div>" +
      '<section><div class="dp-sect-h"><h2>Drivers and vehicle load</h2><span>units to deliver / vehicle capacity</span></div><div class="dp-drivers">' + driversHtml() + "</div></section>" +
      '<div class="dp-tools"><label class="dp-search" for="dpSearch">' + ico("search") + '<input id="dpSearch" type="search" placeholder="Search a customer, an order or a city" value="' + esc(search) + '"></label>' +
      '<div class="dp-seg" role="group" aria-label="Driver">' + segs.map(function (b) { return '<button type="button" class="' + (fDriver === b[0] ? "on" : "") + '" data-drv="' + esc(b[0]) + '" aria-pressed="' + (fDriver === b[0]) + '">' + esc(b[1]) + "</button>"; }).join("") + "</div>" +
      '<select id="dpStock" aria-label="Stock">' + [["", "All stock states"], ["Available", "Available"], ["Partial", "Partial"], ["Not Available", "Not Available"]].map(function (x) { return '<option value="' + x[0] + '"' + (fStock === x[0] ? " selected" : "") + ">" + x[1] + "</option>"; }).join("") + "</select></div>" +
      '<div class="dp-main"><div class="dp-card"><div class="dp-scroll"><table class="dp-table"><thead><tr><th>Priority</th><th>Customer</th><th class="dp-hide-s">City</th><th class="dp-hide-s">Driver</th><th class="r dp-hide-s">Units</th><th>Stock</th></tr></thead><tbody id="dpRows"></tbody></table></div></div>' +
      '<aside class="dp-card" id="dpDetail" aria-live="polite"></aside></div>' +
      "</div>";
    renderTable();
  }

  function driversHtml() {
    var html = data.drivers.map(function (d) {
      var mine = data.orders.filter(function (o) { return o.driver === d.code; });
      var load = mine.reduce(function (a, o) { return a + (Number(o.units) || 0); }, 0);
      var p = d.cap > 0 ? Math.round(load / d.cap * 100) : null;
      return '<div class="dp-drv"><div class="h"><div class="who"><div class="dp-av">' + esc(initials(d.name || d.code)) + '</div><div><div class="n">' + esc(d.name || d.code) + '</div><div class="v">' + ico("truck") + esc(d.vehicle || d.code) +
        (d.fridge ? ' · <span style="color:var(--cold)">' + ico("cold") + "</span>refrigerated" : "") + "</div></div></div>" +
        '<span class="dp-tag">' + mine.length + " stop" + (mine.length === 1 ? "" : "s") + "</span></div>" +
        (p === null ? '<div class="dp-k">Vehicle capacity not set</div>' : '<div class="dp-bar"><i class="' + (p > 100 ? "crit" : p > 85 ? "warn" : "") + '" style="width:' + Math.min(p, 100) + '%"></i></div>') +
        '<div class="meta"><span class="dp-mono">' + num(load) + (d.cap > 0 ? " / " + num(d.cap) : " units") + '</span><span class="dp-mono">' + (p === null ? "" : p + "%") + "</span></div></div>";
    }).join("");
    var none = data.orders.filter(function (o) { return !o.driver; });
    return html + '<div class="dp-drv none"><div class="h"><div class="who"><div class="dp-av">–</div><div><div class="n">Not assigned</div><div class="v">waiting for a driver</div></div></div><span class="dp-tag crit">' + none.length + "</span></div>" +
      '<div class="meta"><span class="dp-mono">' + num(none.reduce(function (a, o) { return a + (Number(o.units) || 0); }, 0)) + " units</span></div></div>";
  }

  function visible() {
    var q = search.trim().toLowerCase();
    return data.orders.filter(function (o) {
      return (!q || (o.customer + " " + o.no + " " + o.city).toLowerCase().indexOf(q) >= 0) &&
        (!fStock || o.stock === fStock) &&
        (fDriver === "" || (fDriver === "-" ? !o.driver : o.driver === fDriver)) &&
        (fSum === "" || fSum === "all" || (fSum === "very" && o.priority === "Very Urgent") || (fSum === "nodrv" && !o.driver) ||
          (fSum === "stock" && hasStockIssue(o)) || (fSum === "cold" && o.cold));
    });
  }

  function renderTable() {
    var vis = visible(), html = "";
    PRIOS.forEach(function (p) {
      var g = vis.filter(function (o) { return o.priority === p[0]; });
      if (!g.length) return;
      html += '<tr class="grp"><td colspan="6">' + p[0] + " · " + g.length + "</td></tr>";
      html += g.map(function (o) {
        var d = drv(o.driver);
        var icons = (o.cold ? '<span class="c" title="Cold chain">' + ico("cold") + "</span>" : "") + (o.bonus ? '<span class="g" title="Bonus line">' + ico("gift") + "</span>" : "");
        return '<tr tabindex="0" data-no="' + esc(o.no) + '" class="' + (sel === o.no ? "sel" : "") + '">' +
          '<td><span class="dp-prio"><span class="dp-dot ' + p[1] + '"></span>' + p[0] + "</span></td>" +
          '<td><div class="dp-cust">' + esc(o.customer) + '</div><div class="dp-ord"><span class="dp-mono">' + esc(o.no) + "</span>" + (icons ? ' · <span class="dp-icons">' + icons + "</span>" : "") + "</div></td>" +
          '<td class="dp-hide-s">' + esc(o.city) + "</td>" +
          '<td class="dp-hide-s">' + (d ? esc(firstName(d.name) || d.code) + (o.stop ? ' <span class="dp-muted">· stop ' + o.stop + "</span>" : "") : '<span class="dp-nodrv">Unassigned</span>') + "</td>" +
          '<td class="r dp-hide-s dp-mono">' + num(o.units) + "</td>" +
          "<td>" + stockTag(o.stock) + "</td></tr>";
      }).join("");
    });
    document.getElementById("dpRows").innerHTML = html || '<tr><td colspan="6" class="dp-empty">No order matches these filters.</td></tr>';
    renderDetail();
  }

  function renderDetail() {
    var o = byNo(sel), el = document.getElementById("dpDetail");
    var shipped = data.shipped || [];
    var shippedHtml = shipped.length ? '<div class="dp-d-sec"><h3>Shipped today</h3><div class="dp-shipped">' +
      shipped.map(function (s) { return '<div><span><span class="dp-dot ok"></span>' + esc(s.no + " · " + s.customer) + '</span><span class="dp-muted">' + esc(s.driver) + "</span></div>"; }).join("") + "</div></div>" : "";
    if (!o) { el.innerHTML = '<div class="dp-empty">Select an order to see its lines and ship it.</div>' + shippedHtml; return; }
    var checks = checksFor(o), blocked = !checks[0][0] || o.stock === "Not Available" || !checks[2][0];
    var bad = checks.filter(function (c) { return !c[0]; }).length;
    el.innerHTML =
      '<div class="dp-d-head"><div class="top"><div><div class="dp-ord">Sales order <span class="dp-mono">' + esc(o.no) + "</span>" + (o.requests ? ' · requests <span class="dp-mono">' + esc(o.requests) + "</span>" : "") + "</div><h2>" + esc(o.customer) + "</h2></div>" +
      '<span class="dp-tag ' + prioCls(o.priority) + '"><span class="dp-dot ' + prioCls(o.priority) + '"></span>' + esc(o.priority) + "</span></div>" +
      '<div class="dp-muted" style="font-size:13px">' + esc([o.address, o.city].filter(function (x) { return x; }).join(", ")) + "</div></div>" +
      '<div class="dp-d-sec"><h3>Delivery</h3><div class="dp-kv">' +
      '<div><div class="dp-k">Amount incl. VAT</div><div class="dp-mono">' + num(o.amount) + "</div></div>" +
      '<div><div class="dp-k">Salesperson</div><div>' + esc(o.salesperson || "–") + "</div></div>" +
      '<div><div class="dp-k">Contact</div><div class="dp-mono">' + esc(o.phone || "–") + "</div></div>" +
      '<div><div class="dp-k">Position in round</div><div>' + (o.stop ? "Stop " + o.stop : "Not planned") + "</div></div></div>" +
      '<label class="dp-k" for="dpAssign">Driver</label><select id="dpAssign"><option value="">Choose a driver</option>' +
      data.drivers.map(function (d) { return '<option value="' + esc(d.code) + '"' + (o.driver === d.code ? " selected" : "") + ">" + esc((d.name || d.code) + (d.vehicle ? " · " + d.vehicle : "") + (d.fridge ? " · refrigerated" : "")) + "</option>"; }).join("") + "</select></div>" +
      '<div class="dp-d-sec"><h3>Lines to ship</h3><div class="dp-scroll"><table class="dp-lines"><thead><tr><th>Item</th><th class="r">Qty</th><th class="r">In stock</th></tr></thead><tbody>' +
      (o.lines || []).map(function (l) {
        var hasStock = l.stock !== null && l.stock !== undefined;
        var cls = !hasStock ? "" : l.stock >= l.qty ? "st-ok" : l.stock > 0 ? "st-warn" : "st-crit";
        return '<tr class="' + (l.bonus ? "bonus" : "") + '"><td><span class="dp-mono dp-muted">' + esc(l.item) + "</span> " + (l.bonus ? "Bonus · " : "") + esc(l.desc) + (l.cold ? ' <span class="dp-tag cold">' + ico("cold") + "cold</span>" : "") + "</td>" +
          '<td class="r dp-mono">' + num(l.qty) + '</td><td class="r dp-mono ' + cls + '">' + (hasStock ? num(l.stock) : "–") + "</td></tr>";
      }).join("") + "</tbody></table></div></div>" +
      '<div class="dp-d-sec"><h3>Before shipping</h3><ul class="dp-checks">' + checks.map(function (c) {
        return '<li class="' + (c[0] ? "" : "ko") + '"><span class="ic">' + ico(c[0] ? "check" : "x") + "</span><span>" + esc(c[1]) + "</span></li>";
      }).join("") + "</ul></div>" +
      '<div class="dp-d-foot"><div class="row"><button type="button" class="dp-btn primary" data-act="ship" data-a1="' + esc(o.no) + '"' + (blocked ? " disabled" : "") + ">" + ico("truck") + "Ship order</button>" +
      '<button type="button" class="dp-btn" data-act="open" data-a1="' + esc(o.no) + '">Open order</button><button type="button" class="dp-btn" data-act="round" data-a1="' + esc(o.no) + '">' + ico("route") + "Round</button></div>" +
      '<div class="dp-note' + (blocked ? " ko" : "") + '">' + (blocked ? bad + " point" + (bad > 1 ? "s" : "") + " to fix before shipping." : "Posts the shipment only. The invoice is created later from the shipped quantities.") + "</div></div>" +
      shippedHtml;
  }

  return { init: init, load: load };
})();

// Appelée par BC (procédure LoadPlan du control add-in)
function LoadPlan(data) { GNCDeliveryPlan.load(data); }
