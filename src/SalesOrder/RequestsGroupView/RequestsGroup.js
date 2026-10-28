// Lot 4 – écran Requests to Group (control add-in "GNC Requests Group View"), style professionnel.
// BC envoie les demandes approuvées déjà réparties en groupes (même règle que le codeunit 90056).
// L'aperçu de la commande est calculé ici avec les mêmes règles de cumul et de bonus ;
// la création réelle de la commande est faite par BC (bouton Create grouped order).
var GNCRequestsGroup = (function () {
  var root, app, data = null, sel = null, fSum = "", search = "";
  var PR = ["Normal", "Urgent", "Very Urgent"];

  var SPRITE =
    '<svg width="0" height="0" style="position:absolute" aria-hidden="true">' +
    '<symbol id="rgi-search" viewBox="0 0 24 24"><circle cx="11" cy="11" r="7"></circle><path d="M20 20l-3.5-3.5"></path></symbol>' +
    '<symbol id="rgi-check" viewBox="0 0 24 24"><path d="M5 12.5l4.5 4.5L19 7.5"></path></symbol>' +
    '<symbol id="rgi-alert" viewBox="0 0 24 24"><path d="M12 8v5M12 16.5v.5"></path><circle cx="12" cy="12" r="9"></circle></symbol>' +
    '<symbol id="rgi-merge" viewBox="0 0 24 24"><path d="M6 4v5a5 5 0 0 0 5 5h7M18 14l-3-3M18 14l-3 3M6 20v-4"></path></symbol>' +
    '<symbol id="rgi-gift" viewBox="0 0 24 24"><rect x="3" y="8" width="18" height="13" rx="1"></rect><path d="M12 8v13M3 12h18M12 8c-2-4-6-4-6-1.5S10 8 12 8zM12 8c2-4 6-4 6-1.5S14 8 12 8z"></path></symbol>' +
    '<symbol id="rgi-cal" viewBox="0 0 24 24"><rect x="3" y="5" width="18" height="16" rx="2"></rect><path d="M3 10h18M8 3v4M16 3v4"></path></symbol>' +
    '<symbol id="rgi-doc" viewBox="0 0 24 24"><path d="M6 3h8l4 4v14H6z"></path><path d="M14 3v4h4M9 12h6M9 16h6"></path></symbol>' +
    '<symbol id="rgi-layers" viewBox="0 0 24 24"><path d="M12 3l9 5-9 5-9-5 9-5z"></path><path d="M3 13l9 5 9-5"></path></symbol>' +
    '<symbol id="rgi-refresh" viewBox="0 0 24 24"><path d="M20 11a8 8 0 1 0-2.3 5.7M20 4v7h-7"></path></symbol>' +
    "</svg>";

  function ico(n) { return '<svg class="rg-i"><use href="#rgi-' + n + '"></use></svg>'; }
  function act(name, a1, a2) { Microsoft.Dynamics.NAV.InvokeExtensibilityMethod("Action", [name, a1 || "", a2 || ""]); }
  function esc(s) { return String(s === undefined || s === null ? "" : s).replace(/[&<>"']/g, function (c) { return { "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" }[c]; }); }
  function num(v) { return (Math.round((Number(v) || 0) * 100) / 100).toLocaleString(); }
  function amt(v) { return Math.round(Number(v) || 0).toLocaleString(); }
  function prioCls(p) { return p === "Very Urgent" ? "crit" : p === "Urgent" ? "warn" : ""; }
  function initials(name) { return String(name || "?").split(" ").filter(function (w) { return w; }).map(function (w) { return w.charAt(0); }).slice(0, 2).join("").toUpperCase(); }
  function group(key) { var g = null; data.groups.forEach(function (x) { if (x.key === key) g = x; }); return g; }
  function unique(arr) { var out = []; arr.forEach(function (x) { if (out.indexOf(x) < 0) out.push(x); }); return out; }

  function init(container) {
    root = container;
    root.innerHTML = SPRITE + '<div id="rgApp"><div class="rg-empty">Loading the requests…</div></div>';
    app = document.getElementById("rgApp");
    root.addEventListener("click", function (e) {
      var t = e.target.closest("[data-sum],[data-key],[data-act]");
      if (!t || t.disabled) return;
      if (t.hasAttribute("data-sum")) { fSum = fSum === t.getAttribute("data-sum") ? "" : t.getAttribute("data-sum"); render(); }
      else if (t.hasAttribute("data-key")) { sel = t.getAttribute("data-key"); render(); }
      else act(t.getAttribute("data-act"), t.getAttribute("data-a1"));
    });
    root.addEventListener("keydown", function (e) {
      var t = e.target.closest("[data-key]");
      if (t && (e.key === "Enter" || e.key === " ")) { e.preventDefault(); sel = t.getAttribute("data-key"); render(); }
    });
    root.addEventListener("input", function (e) {
      if (e.target.id === "rgSearch") { search = e.target.value; renderList(); }
    });
  }

  function load(d) {
    data = d;
    data.groups = data.groups || [];
    data.created = data.created || [];
    data.rule = data.rule || {};
    if (!group(sel)) sel = data.groups.length ? data.groups[0].key : null;
    render();
  }

  // Aperçu de la commande : mêmes règles que le codeunit 90056 (cumul : même article, variante, unité,
  // magasin, prix, remise et commercial) et que le bonus du lot 5 (sur la ligne cumulée).
  function preview(g) {
    var ok = g.requests.filter(function (r) { return r.pin; });
    var skipped = g.requests.filter(function (r) { return !r.pin; });
    var lines = [];
    ok.forEach(function (r) {
      (r.lines || []).forEach(function (l) {
        if (l.type !== "Item") return;
        var m = null;
        if (data.rule.merge && !l.attached)
          lines.forEach(function (x) {
            if (!m && x.item === l.item && x.variant === l.variant && x.uom === l.uom && x.location === l.location && x.price === l.price && x.disc === l.disc && x.sp === r.salesperson) m = x;
          });
        if (m) { m.qty += l.qty; m.from.push(r.no); }
        else lines.push({ item: l.item, desc: l.desc, qty: l.qty, variant: l.variant, uom: l.uom, location: l.location, price: l.price, disc: l.disc, sp: r.salesperson, spName: r.salespersonName, from: [r.no] });
      });
    });
    var out = [];
    lines.forEach(function (l) {
      var b = null;
      (g.bonus || []).forEach(function (x) { if (x.item === l.item && l.qty >= x.min) b = x; });
      var extra = b ? b.add + (g.gov ? b.moh : 0) : 0;
      var pct = Math.min(100, l.disc + extra);
      l.pct = pct;
      l.amount = l.qty * l.price * (1 - pct / 100);
      out.push(l);
      if (b && b.qty > 0) out.push({ item: l.item, desc: l.desc, qty: b.qty, spName: l.spName, pct: 100, amount: 0, bonus: true, from: l.from });
    });
    var prio = ok.reduce(function (a, r) { return PR.indexOf(r.priority) > PR.indexOf(a) ? r.priority : a; }, "Normal");
    return { ok: ok, skipped: skipped, lines: out, prio: prio, total: out.reduce(function (a, l) { return a + l.amount; }, 0) };
  }
  function mergedCount(p) { return p.lines.filter(function (l) { return !l.bonus && l.from.length > 1; }).length; }

  function render() {
    if (!data) return;
    var prevs = data.groups.map(preview);
    var allReq = 0, noPin = 0;
    data.groups.forEach(function (g) { allReq += g.requests.length; noPin += g.requests.filter(function (r) { return !r.pin; }).length; });
    var s = [
      ["all", "Approved requests", allReq, "waiting for an order", "acc"],
      ["groups", "Orders to create", prevs.filter(function (p) { return p.ok.length; }).length, data.rule.sameDay ? "one per customer and day" : "one per customer", "acc"],
      ["merged", "Merged lines", prevs.reduce(function (a, p) { return a + mergedCount(p); }, 0), "same item from several requests", "ok"],
      ["pin", "Not confirmed", noPin, "salesperson PIN missing", "warn"],
      ["urgent", "Urgent groups", prevs.filter(function (p) { return p.prio !== "Normal"; }).length, "urgent or very urgent", "crit"]
    ];
    app.innerHTML =
      '<div class="rg-wrap">' +
      '<div class="rg-title"><div><div class="rg-crumb">GNC Sales · Request Collection</div><h1>Requests to Group</h1>' +
      '<div class="rg-sub"><span>' + ico("cal") + esc(data.dateText) + "</span></div></div>" +
      '<div class="rg-actions"><button type="button" class="rg-btn" data-act="refresh">' + ico("refresh") + 'Refresh</button><button type="button" class="rg-btn" data-act="list">List view</button><button type="button" class="rg-btn" data-act="setup">Grouping setup</button>' +
      '<button type="button" class="rg-btn primary" data-act="createAll"' + (prevs.some(function (p) { return p.ok.length; }) ? "" : " disabled") + ">" + ico("layers") + "Create all grouped orders</button></div></div>" +
      '<div class="rg-sum" role="group" aria-label="Summary filters">' + s.map(function (x) {
        return '<button type="button" class="' + (fSum === x[0] ? "on" : "") + '" data-sum="' + x[0] + '" aria-pressed="' + (fSum === x[0]) + '"><span class="l"><span class="rg-dot ' + x[4] + '"></span>' + x[1] + '</span><span class="v">' + x[2] + '</span><span class="s">' + x[3] + "</span></button>";
      }).join("") + "</div>" +
      '<div class="rg-rule"><span>Grouping rule</span><span class="rg-chip"><span class="rg-dot acc"></span>' + (data.rule.sameDay ? "Same customer and same day" : "Same customer, all dates") + "</span>" +
      '<span class="rg-chip">' + ico("merge") + (data.rule.merge ? "Identical lines are merged" : "Lines are not merged") + '</span><span class="rg-chip">Approved requests only</span>' +
      '<label class="rg-search" for="rgSearch">' + ico("search") + '<input id="rgSearch" type="search" placeholder="Search a customer or a request" value="' + esc(search) + '"></label></div>' +
      '<div class="rg-main"><div class="rg-card"><div class="rg-list-h"><span>' + (data.rule.sameDay ? "Customer and day" : "Customer") + '</span><span id="rgCount"></span></div><div id="rgGroups"></div></div>' +
      '<aside class="rg-card" id="rgDetail" aria-live="polite"></aside></div></div>';
    renderList();
  }

  function renderList() {
    var q = search.trim().toLowerCase();
    var vis = data.groups.filter(function (g) {
      var p = preview(g);
      return (!q || (g.name + " " + g.customerNo + " " + g.requests.map(function (r) { return r.no; }).join(" ")).toLowerCase().indexOf(q) >= 0) &&
        (fSum === "" || fSum === "all" || fSum === "groups" || (fSum === "merged" && mergedCount(p) > 0) || (fSum === "pin" && p.skipped.length > 0) || (fSum === "urgent" && p.prio !== "Normal"));
    });
    document.getElementById("rgCount").textContent = vis.length + " group" + (vis.length === 1 ? "" : "s");
    document.getElementById("rgGroups").innerHTML = vis.map(function (g) {
      var p = preview(g), sps = unique(g.requests.map(function (r) { return r.salespersonName || r.salesperson; }));
      return '<div class="rg-item' + (sel === g.key ? " sel" : "") + '" tabindex="0" data-key="' + esc(g.key) + '">' +
        '<div class="t"><span class="n">' + esc(g.name) + '</span><span class="rg-tag ' + prioCls(p.prio) + '"><span class="rg-dot ' + prioCls(p.prio) + '"></span>' + p.prio + "</span></div>" +
        '<div class="m"><span>' + ico("cal") + esc(g.dateText) + "</span><span>" + g.requests.length + " request" + (g.requests.length === 1 ? "" : "s") + "</span>" +
        '<span class="rg-avs">' + sps.map(function (n) { return '<span class="rg-av" title="' + esc(n) + '">' + esc(initials(n)) + "</span>"; }).join("") + "</span>" +
        '<span class="rg-mono">' + amt(p.total) + "</span>" + (p.skipped.length ? '<span class="rg-tag warn">' + p.skipped.length + " without PIN</span>" : "") + "</div></div>";
    }).join("") || '<div class="rg-empty">No approved request waiting.</div>';
    renderDetail();
  }

  function renderDetail() {
    var g = group(sel), el = document.getElementById("rgDetail");
    var createdHtml = data.created.length ? '<div class="rg-d-sec"><h3>Created in this session</h3><div class="rg-created">' + data.created.map(function (c) {
      return '<div><span><span class="rg-dot ok"></span> Order <span class="rg-link rg-mono" data-act="openOrder" data-a1="' + esc(c.order) + '">' + esc(c.order) + "</span> · " + esc(c.customer) + '</span><span class="rg-muted rg-mono">' + esc(c.requests) + "</span></div>";
    }).join("") + "</div></div>" : "";
    if (!g) { el.innerHTML = '<div class="rg-empty">' + (data.groups.length ? "Select a customer to preview the order." : "All approved requests have been grouped.") + "</div>" + createdHtml; return; }
    var p = preview(g);
    var checks = [
      [true, "Same customer, bill-to customer, delivery address and currency"],
      [p.skipped.length === 0, p.skipped.length ? "Request " + p.skipped.map(function (r) { return r.no; }).join(", ") + " is not confirmed by the salesperson PIN and stays in the list" : "All salespeople confirmed by PIN"],
      [true, p.prio === "Normal" ? "Delivery priority Normal" : "Delivery priority " + p.prio + ", taken from the most urgent request"],
      [true, "Requests are archived as Won after the order is created"]
    ];
    el.innerHTML =
      '<div class="rg-d-head"><div class="top"><div><div class="rg-muted" style="font-size:12.5px">' + esc(g.customerNo) + " · " + esc(g.dateText) + "</div><h2>" + esc(g.name) + "</h2></div>" +
      '<span class="rg-tag ' + prioCls(p.prio) + '"><span class="rg-dot ' + prioCls(p.prio) + '"></span>' + p.prio + "</span></div></div>" +
      '<div class="rg-d-sec"><h3>Requests <span>' + p.ok.length + " grouped" + (p.skipped.length ? ", " + p.skipped.length + " skipped" : "") + "</span></h3>" +
      '<div class="rg-scroll"><table class="rg-t"><thead><tr><th>Request</th><th>Salesperson</th><th>Lines</th><th>Priority</th><th class="r">PIN</th></tr></thead><tbody>' +
      g.requests.map(function (r) {
        var items = (r.lines || []).filter(function (l) { return l.type === "Item"; }).map(function (l) { return num(l.qty) + " × " + l.item; }).join(", ");
        return '<tr class="' + (r.pin ? "" : "skip") + '"><td><span class="rg-link rg-mono" data-act="openRequest" data-a1="' + esc(r.no) + '">' + esc(r.no) + "</span></td><td>" + esc(r.salespersonName || r.salesperson || "–") + "</td><td>" + esc(items || "–") + "</td>" +
          '<td><span class="rg-dot ' + prioCls(r.priority) + '"></span> ' + esc(r.priority) + '</td><td class="r">' + (r.pin ? '<span class="rg-tag ok">' + ico("check") + "confirmed</span>" : '<span class="rg-tag warn">' + ico("alert") + "missing</span>") + "</td></tr>";
      }).join("") + "</tbody></table></div></div>" +
      '<div class="rg-d-sec"><h3>Order preview <span>' + (data.rule.merge ? "one line per item, salesperson and discount" : "one line per request line") + "</span></h3>" +
      '<div class="rg-scroll"><table class="rg-t"><thead><tr><th>Item</th><th class="r">Qty</th><th class="r">Disc.</th><th class="r">Amount</th><th>From</th></tr></thead><tbody>' +
      (p.lines.map(function (l) {
        var merged = !l.bonus && l.from.length > 1;
        return '<tr class="' + (l.bonus ? "bonus" : merged ? "merged" : "") + '"><td>' + (l.bonus ? ico("gift") + " Bonus · " : "") + '<span class="rg-mono rg-muted">' + esc(l.item) + "</span> " + esc(l.desc) +
          '<div class="rg-muted" style="font-size:12px">' + esc(l.spName || "") + "</div></td>" +
          '<td class="r rg-mono">' + num(l.qty) + '</td><td class="r rg-mono">' + num(l.pct) + '%</td><td class="r rg-mono">' + (l.bonus ? "free" : amt(l.amount)) + "</td>" +
          '<td><span class="rg-from">' + (l.bonus ? '<span class="rg-tag gift">bonus rule</span>' : l.from.map(function (n) { return '<span class="rg-tag' + (merged ? " acc" : "") + '">' + esc(n) + "</span>"; }).join("")) + "</span></td></tr>";
      }).join("") || '<tr><td colspan="5" class="rg-muted">No item line in the confirmed requests.</td></tr>') +
      "</tbody></table></div>" +
      (p.lines.some(function (l) { return !l.bonus && l.from.length > 1; }) ? '<div class="rg-note">' + ico("merge") + " Lines marked in green come from several requests. The detail per request is kept on the order.</div>" : "") + "</div>" +
      '<div class="rg-d-sec"><h3>Checks</h3><ul class="rg-checks">' + checks.map(function (c) {
        return '<li class="' + (c[0] ? "" : "ko") + '"><span class="ic">' + ico(c[0] ? "check" : "alert") + "</span><span>" + esc(c[1]) + "</span></li>";
      }).join("") + "</ul></div>" +
      '<div class="rg-d-foot"><div class="row"><button type="button" class="rg-btn primary" data-act="create" data-a1="' + esc(p.ok.length ? p.ok[0].no : "") + '"' + (p.ok.length ? "" : " disabled") + ">" + ico("doc") + "Create grouped order</button>" +
      '<button type="button" class="rg-btn" data-act="openRequest" data-a1="' + esc(g.requests[0].no) + '">Open first request</button>' +
      '<div class="rg-total"><div class="k">Order total excl. VAT (estimate)</div><div class="v rg-mono">' + amt(p.total) + "</div></div></div>" +
      '<div class="rg-note">' + (p.ok.length ? "Creates one sales order from " + p.ok.length + " request" + (p.ok.length > 1 ? "s" : "") + " (" + p.ok.map(function (r) { return r.no; }).join(", ") + ")." : "No confirmed request in this group: enter the salesperson PIN on the request first.") + "</div></div>" +
      createdHtml;
  }

  return { init: init, load: load };
})();

// Appelée par BC (procédure LoadGroups du control add-in)
function LoadGroups(data) { GNCRequestsGroup.load(data); }
