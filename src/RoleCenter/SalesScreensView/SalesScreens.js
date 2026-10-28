// Écrans Sales Overview, Customer 360 et Price Simulator (control add-in "GNC Sales Screens View").
// BC envoie les données de la vue (Render) ; chaque clic renvoie Action('open', écran, n°) à BC.
// Les textes viennent de BC : ils sont toujours insérés avec esc().
var GNCSalesScreens = (function () {
  var root, app;
  var MONTHS = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
  var SPRITE =
    '<svg width="0" height="0" style="position:absolute" aria-hidden="true">' +
    '<symbol id="sci-check" viewBox="0 0 24 24"><path d="M5 12.5l4.5 4.5L19 7.5"></path></symbol>' +
    '<symbol id="sci-x" viewBox="0 0 24 24"><path d="M6 6l12 12M18 6L6 18"></path></symbol>' +
    '<symbol id="sci-cal" viewBox="0 0 24 24"><rect x="3" y="5" width="18" height="16" rx="2"></rect><path d="M3 10h18M8 3v4M16 3v4"></path></symbol>' +
    '<symbol id="sci-arrow" viewBox="0 0 24 24"><path d="M9 6l6 6-6 6"></path></symbol>' +
    '<symbol id="sci-gift" viewBox="0 0 24 24"><rect x="3" y="8" width="18" height="13" rx="1"></rect><path d="M12 8v13M3 12h18M12 8c-2-4-6-4-6-1.5S10 8 12 8zM12 8c2-4 6-4 6-1.5S14 8 12 8z"></path></symbol>' +
    '<symbol id="sci-pin" viewBox="0 0 24 24"><path d="M12 21s-7-6.2-7-11.5A7 7 0 0 1 19 9.5C19 14.8 12 21 12 21z"></path><circle cx="12" cy="9.5" r="2.5"></circle></symbol>' +
    '<symbol id="sci-phone" viewBox="0 0 24 24"><path d="M5 4h4l2 5-2.5 1.5a11 11 0 0 0 5 5L15 13l5 2v4a2 2 0 0 1-2 2A16 16 0 0 1 3 6a2 2 0 0 1 2-2z"></path></symbol>' +
    '<symbol id="sci-refresh" viewBox="0 0 24 24"><path d="M20 11a8 8 0 1 0-2.3 5.7M20 4v7h-7"></path></symbol>' +
    "</svg>";

  function ico(n) { return '<svg class="sc-i"><use href="#sci-' + n + '"></use></svg>'; }
  function act(name, a1, a2) { Microsoft.Dynamics.NAV.InvokeExtensibilityMethod("Action", [name, a1 || "", a2 || ""]); }
  function esc(s) { return String(s === undefined || s === null ? "" : s).replace(/[&<>"']/g, function (c) { return { "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" }[c]; }); }
  function amt(v) { return Math.round(Number(v) || 0).toLocaleString(); }
  function num(v) { return (Math.round((Number(v) || 0) * 100) / 100).toLocaleString(); }
  function pct(a, b) { return b ? Math.round(a / b * 100) : 0; }
  function barCls(p) { return p < 50 ? "crit" : p < 80 ? "warn" : ""; }
  function initials(name) { return String(name || "?").split(" ").filter(function (w) { return w; }).map(function (w) { return w.charAt(0); }).slice(0, 2).join("").toUpperCase(); }

  function init(container) {
    root = container;
    root.innerHTML = SPRITE + '<div id="scApp"><div class="sc-empty">Loading…</div></div>';
    app = document.getElementById("scApp");
    root.addEventListener("click", function (e) {
      var t = e.target.closest("[data-open],[data-act]");
      if (!t) return;
      if (t.hasAttribute("data-open")) act("open", t.getAttribute("data-open"), t.getAttribute("data-arg"));
      else act(t.getAttribute("data-act"));
    });
    root.addEventListener("keydown", function (e) {
      var t = e.target.closest("[data-open]");
      if (t && t.tagName !== "BUTTON" && (e.key === "Enter" || e.key === " ")) { e.preventDefault(); act("open", t.getAttribute("data-open"), t.getAttribute("data-arg")); }
    });
  }

  function render(view, d) {
    d = d || {};
    var html = view === "overview" ? overview(d) : view === "customer" ? customer(d) : view === "simulator" ? simulator(d) : '<div class="sc-empty">Unknown view</div>';
    app.innerHTML = '<div class="sc-wrap">' + html + "</div>";
  }

  // ---------- Éléments communs ----------
  function title(crumb, h, sub, actions) {
    return '<div class="sc-title"><div><div class="sc-crumb">' + crumb + "</div><h1>" + h + '</h1><div class="sc-sub">' + sub + '</div></div><div class="sc-actions">' + (actions || "") + "</div></div>";
  }
  function cell(label, value, sub, color, openKey) {
    var tag = openKey ? 'button type="button" data-open="' + openKey + '"' : "div";
    return "<" + tag + '><span class="l"><span class="sc-dot ' + color + '"></span>' + label + '</span><span class="v">' + value + '</span><span class="s">' + sub + "</span></" + (openKey ? "button" : "div") + ">";
  }
  function bars(list) {
    var mx = list.reduce(function (m, r) { return Math.max(m, r.count); }, 1);
    return list.map(function (r) {
      return '<div><div style="display:flex;justify-content:space-between;font-size:13px"><span>' + esc(r.reason) + '</span><span class="sc-mono">' + r.count + '</span></div><div class="sc-bar"><i class="crit" style="width:' + (r.count / mx * 100) + '%"></i></div></div>';
    }).join("");
  }
  // Courbe mensuelle en milliers : année en cours en aire, année précédente en trait (une seule échelle)
  function lineChart(cur, prev) {
    var W = 640, H = 210, L = 48, R = 12, T = 16, B = 28;
    var k = function (v) { return v === null || v === undefined ? null : v / 1000; };
    var c = (cur || []).map(k), p = (prev || []).map(k);
    var all = c.concat(p).filter(function (v) { return v !== null; });
    var mx = all.length ? Math.max.apply(null, all) : 0;
    var step = mx > 500 ? 100 : mx > 100 ? 50 : 10, max = Math.max(step, Math.ceil(mx / step) * step);
    function x(i) { return L + i * (W - L - R) / 11; }
    function y(v) { return T + (H - T - B) * (1 - v / max); }
    function pts(a) { var o = []; a.forEach(function (v, i) { if (v !== null) o.push([x(i), y(v)]); }); return o; }
    var pc = pts(c), pp = pts(p), ticks = [0, max / 2, max];
    var s = '<svg class="sc-chart" viewBox="0 0 ' + W + " " + H + '" role="img" aria-label="Monthly sales">';
    ticks.forEach(function (t) {
      s += '<line x1="' + L + '" x2="' + (W - R) + '" y1="' + y(t) + '" y2="' + y(t) + '" stroke="var(--line)" stroke-width="1"></line>' +
        '<text x="' + (L - 8) + '" y="' + (y(t) + 4) + '" text-anchor="end" font-size="11" fill="var(--faint)" font-family="IBM Plex Mono, monospace">' + amt(t) + "</text>";
    });
    MONTHS.forEach(function (m, i) { s += '<text x="' + x(i) + '" y="' + (H - 8) + '" text-anchor="middle" font-size="11" fill="var(--faint)">' + m + "</text>"; });
    if (pp.length) s += '<polyline points="' + pp.map(function (q) { return q.join(","); }).join(" ") + '" fill="none" stroke="var(--line-strong)" stroke-width="2"></polyline>';
    if (pc.length) {
      var last = pc[pc.length - 1], lastVal = c.filter(function (v) { return v !== null; }).slice(-1)[0];
      s += '<path d="M' + pc[0][0] + "," + y(0) + " " + pc.map(function (q) { return "L" + q[0] + "," + q[1]; }).join(" ") + " L" + last[0] + "," + y(0) + ' Z" fill="var(--accent-soft)"></path>' +
        '<polyline points="' + pc.map(function (q) { return q.join(","); }).join(" ") + '" fill="none" stroke="var(--accent)" stroke-width="2.5" stroke-linejoin="round"></polyline>' +
        '<circle cx="' + last[0] + '" cy="' + last[1] + '" r="4" fill="var(--accent)"></circle>' +
        '<text x="' + last[0] + '" y="' + Math.max(12, last[1] - 10) + '" text-anchor="middle" font-size="11.5" font-weight="600" fill="var(--ink)" font-family="IBM Plex Mono, monospace">' + amt(lastVal) + "k</text>";
    }
    return s + "</svg>";
  }
  function sumYear(a) { return (a || []).reduce(function (t, v) { return t + (Number(v) || 0); }, 0); }

  // ---------- Sales Overview ----------
  function overview(d) {
    var t = d.tiles || {}, pl = d.pipeline || {};
    var monthDelta = t.salesMonthPrev ? Math.round((t.salesMonth - t.salesMonthPrev) / t.salesMonthPrev * 100) : null;
    var months = (d.monthly || []).filter(function (v) { return v !== null; }).length;
    var ytd = sumYear(d.monthly), ytdPrev = sumYear((d.monthlyPrev || []).slice(0, months));
    var closed = (d.won || 0) + (d.failed || 0);
    var steps = [["requests", "Requests", pl.requests], ["grouping", "Approved", pl.approved], ["orders", "Orders", pl.orders], ["delivery", "To ship", pl.toShip], ["toInvoice", "To invoice", pl.toInvoice]];
    return title("GNC Sales", "Sales Overview", "<span>" + ico("cal") + esc(d.dateText) + "</span>",
        '<button type="button" class="sc-btn" data-act="refresh">' + ico("refresh") + 'Refresh</button><button type="button" class="sc-btn primary" data-open="newRequest">New request</button>') +
      '<div class="sc-sum">' +
      cell("Open requests", t.openRequests, "being collected", "acc", "requests") +
      cell("To group", t.toGroup, "approved, no order yet", t.toGroup ? "warn" : "ok", "grouping") +
      cell("Orders to ship", t.toShip, "released, not shipped", "acc", "delivery") +
      cell("Very urgent", t.veryUrgent, t.veryUrgentNoDriver + " without driver", t.veryUrgent ? "crit" : "ok", "delivery") +
      cell("Sales this month", amt(t.salesMonth), monthDelta === null ? esc(d.currency) + " excl. VAT" : (monthDelta >= 0 ? "+" : "") + monthDelta + "% vs last year", monthDelta !== null && monthDelta < 0 ? "warn" : "ok", "invoices") +
      "</div>" +
      '<div class="sc-cols"><div class="sc-stack">' +
      '<div class="sc-card"><div class="sc-card-h"><h2>Salesperson targets ' + esc(d.year) + "</h2><span>actual vs annual target, " + esc(d.currency) + '</span></div><div class="sc-card-b"><div class="sc-scroll"><table class="sc-t">' +
      '<thead><tr><th>Salesperson</th><th>Type</th><th style="width:34%">Progress</th><th class="r">Actual</th><th class="r">Target</th><th class="r">%</th></tr></thead><tbody>' +
      ((d.targets || []).map(function (s) {
        var p = pct(s.actual, s.target);
        return "<tr><td><b>" + esc(s.name) + '</b> <span class="sc-faint sc-mono">' + esc(s.code) + '</span></td><td class="sc-muted">' + esc(s.type) + '</td><td><div class="sc-bar"><i class="' + barCls(p) + '" style="width:' + Math.min(p, 100) + '%"></i></div></td>' +
          '<td class="r sc-mono">' + amt(s.actual) + '</td><td class="r sc-mono sc-muted">' + amt(s.target) + '</td><td class="r sc-mono"><b>' + p + "%</b></td></tr>";
      }).join("") || '<tr><td colspan="6" class="sc-muted">No salesperson target for this year.</td></tr>') +
      '</tbody></table></div><div style="margin-top:10px"><button type="button" class="sc-btn" data-open="targets">Salesperson targets</button></div></div></div>' +
      '<div class="sc-card"><div class="sc-card-h"><h2>Monthly sales</h2><span>thousand ' + esc(d.currency) + " · " + amt(ytd / 1000) + "k year to date" + (ytdPrev ? ", " + (ytd >= ytdPrev ? "+" : "") + Math.round((ytd - ytdPrev) / ytdPrev * 100) + "% vs last year" : "") + "</span></div>" +
      lineChart(d.monthly, d.monthlyPrev) + '<div class="sc-legend"><span><i class="sc-sw"></i>' + esc(d.year) + '</span><span><i class="sc-sw prev"></i>' + esc(d.year - 1) + "</span></div></div>" +
      '<div class="sc-card"><div class="sc-card-h"><h2>From request to invoice</h2><span>documents in progress</span></div><div class="sc-card-b"><div class="sc-pipe">' +
      steps.map(function (s) { return '<button type="button" data-open="' + s[0] + '"><span class="n">' + amt(s[2]) + '</span><span class="t">' + s[1] + "</span></button>"; }).join("") +
      "</div></div></div></div>" +
      '<div class="sc-stack">' +
      '<div class="sc-card"><div class="sc-card-h"><h2>Needs attention</h2><span>' + (d.attention || []).length + ' items</span></div><div class="sc-card-b">' +
      ((d.attention || []).map(function (a) {
        return '<div class="sc-att" tabindex="0" role="button" data-open="' + esc(a.key) + '"><span class="sc-dot ' + esc(a.level) + '"></span><span><div class="t">' + esc(a.text) + '</div><div class="d">' + esc(a.detail) + '</div></span><span class="sc-faint">' + ico("arrow") + "</span></div>";
      }).join("") || '<div class="sc-muted">Nothing to handle right now.</div>') + "</div></div>" +
      '<div class="sc-card"><div class="sc-card-h"><h2>Requests won and failed</h2><span>' + esc(d.monthName) + '</span></div><div class="sc-card-b">' +
      '<div class="sc-kv" style="margin-bottom:12px"><div><div class="sc-k">Won</div><div class="sc-big">' + (d.won || 0) + '</div></div><div><div class="sc-k">Failed</div><div class="sc-big">' + (d.failed || 0) + "</div></div></div>" +
      '<div class="sc-bar" style="height:10px"><i style="width:' + pct(d.won || 0, closed) + '%"></i></div><div class="sc-note" style="margin-top:6px">' + (closed ? pct(d.won, closed) + "% conversion of closed requests" : "No request closed this month") + "</div>" +
      '<div style="margin-top:10px"><button type="button" class="sc-btn" data-open="outcomes">Quote archives</button></div></div></div>' +
      '<div class="sc-card"><div class="sc-card-h"><h2>Failed sale reasons</h2><span>' + esc(d.year) + '</span></div><div class="sc-card-b" style="display:grid;gap:10px">' +
      (bars(d.reasons || []) || '<div class="sc-muted">No failed request this year.</div>') + "</div></div>" +
      "</div></div>";
  }

  // ---------- Customer 360 ----------
  function customer(d) {
    var t = d.target || {}, q = d.quotes || {}, o = d.orders || {};
    var p = pct(t.actual, t.target), closed = (q.won || 0) + (q.failed || 0);
    var cond = (d.discounts || []).map(function (x) { return '<tr><td><span class="sc-tag acc">Discount</span></td><td>' + esc(x.what) + '</td><td class="r sc-mono">' + num(x.pct) + "%</td></tr>"; }).join("") +
      (d.bonus || []).map(function (x) { return '<tr><td><span class="sc-tag gift">' + ico("gift") + "Bonus</span></td><td>" + esc(x.what) + '</td><td class="r">' + esc(x.detail) + "</td></tr>"; }).join("");
    return title("GNC Sales · Customers", "Customer 360", '<span class="sc-faint">Use the arrows of the page to move to the next customer.</span>',
        '<button type="button" class="sc-btn" data-act="refresh">' + ico("refresh") + 'Refresh</button><button type="button" class="sc-btn" data-open="customerCard">Customer card</button>') +
      '<div class="sc-card"><div class="sc-card-b" style="padding-top:16px;display:grid;gap:12px">' +
      '<div class="sc-head"><div class="sc-av">' + esc(initials(d.name)) + '</div><div style="min-width:0"><div class="sc-faint sc-mono" style="font-size:12.5px">' + esc(d.no) + '</div><div style="font-size:20px;font-weight:700">' + esc(d.name) + "</div>" +
      '<div class="sc-sub"><span>' + ico("pin") + esc(d.city || "no city") + "</span><span>" + ico("phone") + esc(d.phone || "no phone") + "</span></div></div>" +
      '<div class="sc-chips">' + (d.sector ? '<span class="sc-tag ' + (d.sector === "Government" ? "warn" : "acc") + '">' + esc(d.sector) + "</span>" : "") + (d.type ? '<span class="sc-tag">' + esc(d.type) + "</span>" : "") + (d.region ? '<span class="sc-tag">' + esc(d.region) + "</span>" : "") + "</div></div>" +
      '<ul class="sc-checks">' + (d.checks || []).map(function (c) { return '<li class="' + (c.ok ? "" : "ko") + '"><span class="ic">' + ico(c.ok ? "check" : "x") + "</span>" + esc(c.label) + "</li>"; }).join("") + "</ul>" +
      (d.noCR ? '<div class="sc-note crit">This customer has no CR No.: new sales documents are refused until it is filled in.</div>' : "") + "</div></div>" +
      '<div class="sc-sum four">' +
      cell("Target " + esc(t.year), t.target ? p + "%" : "–", t.target ? amt(t.actual) + " of " + amt(t.target) : amt(t.actual) + " sold, no target", !t.target ? "acc" : p >= 80 ? "ok" : p >= 50 ? "warn" : "crit", "targets") +
      cell("Open orders", o.count, amt(o.amount) + " " + esc(d.currency) + " incl. VAT", "acc", "orders") +
      cell("Requests won", q.won, q.failed + " failed · " + (closed ? pct(q.won, closed) : 0) + "% conversion", q.failed > q.won / 2 ? "warn" : "ok", "archives") +
      cell("Balance", amt(d.balance), esc(d.currency) + " due by the customer", "acc", "ledger") +
      "</div>" +
      '<div class="sc-cols"><div class="sc-stack">' +
      '<div class="sc-card"><div class="sc-card-h"><h2>Sales by month</h2><span>thousand ' + esc(d.currency) + " · last year " + amt(d.prevActual) + "</span></div>" + lineChart(d.monthly, d.monthlyPrev) +
      '<div class="sc-legend"><span><i class="sc-sw"></i>' + esc(t.year) + '</span><span><i class="sc-sw prev"></i>' + esc(t.year - 1) + "</span></div></div>" +
      '<div class="sc-card"><div class="sc-card-h"><h2>Last posted invoices</h2><span>' + (d.invoices || []).length + ' shown</span></div><div class="sc-card-b"><div class="sc-scroll"><table class="sc-t">' +
      '<thead><tr><th>Invoice</th><th>Date</th><th class="r">Amount incl. VAT</th></tr></thead><tbody>' +
      ((d.invoices || []).map(function (i) { return '<tr><td class="sc-mono"><span class="sc-link" tabindex="0" data-open="invoice" data-arg="' + esc(i.no) + '">' + esc(i.no) + '</span></td><td class="sc-muted">' + esc(i.date) + '</td><td class="r sc-mono">' + amt(i.amount) + "</td></tr>"; }).join("") || '<tr><td colspan="3" class="sc-muted">No posted invoice.</td></tr>') +
      "</tbody></table></div></div></div></div>" +
      '<div class="sc-stack">' +
      '<div class="sc-card"><div class="sc-card-h"><h2>Salespeople</h2><span>card and assignments</span></div><div class="sc-card-b">' +
      ((d.salespeople || []).map(function (s) { return '<div class="sc-att static"><span class="sc-av small">' + esc(initials(s.name || s.code)) + '</span><span><div class="t">' + esc(s.name) + ' <span class="sc-faint sc-mono">' + esc(s.code) + '</span></div><div class="d">' + esc(s.source) + "</div></span><span></span></div>"; }).join("") || '<div class="sc-muted">No salesperson.</div>') +
      "</div></div>" +
      '<div class="sc-card"><div class="sc-card-h"><h2>Commercial conditions</h2><span>Discount and Bonus Setup</span></div><div class="sc-card-b"><div class="sc-scroll"><table class="sc-t"><tbody>' +
      (cond || '<tr><td class="sc-muted">No specific condition. Standard prices apply.</td></tr>') + "</tbody></table></div>" +
      '<div style="display:flex;gap:8px;flex-wrap:wrap;margin-top:10px"><button type="button" class="sc-btn" data-open="discounts">Discount setup</button><button type="button" class="sc-btn" data-open="bonus">Bonus setup</button></div></div></div>' +
      '<div class="sc-card"><div class="sc-card-h"><h2>Failed sale reasons</h2><span>' + (q.failed || 0) + " failed request" + (q.failed === 1 ? "" : "s") + '</span></div><div class="sc-card-b" style="display:grid;gap:10px">' +
      (bars(d.reasons || []) || '<div class="sc-muted">No failed request.</div>') + "</div></div>" +
      "</div></div>";
  }

  // ---------- Price Simulator ----------
  function simulator(d) {
    var head = title("GNC Sales · Discount & Bonus", "Price Simulator", "<span>Check which discount, bonus and MOH discount apply, without creating a document.</span>",
      '<button type="button" class="sc-btn" data-open="discounts">Discount setup</button><button type="button" class="sc-btn" data-open="bonus">Bonus setup</button>');
    if (d.empty) return head + '<div class="sc-card"><div class="sc-empty">' + esc(d.empty) + "</div></div>";
    var b = d.bonus || {};
    var ladder = (d.ladder || []).map(function (l, i) {
      var cls = i === d.winner ? "win" : l.found ? "" : "none";
      return '<div class="' + cls + '"><span class="rank">' + (i + 1) + "</span><span>" + esc(l.label) + '</span><span class="sc-mono">' + (l.found ? num(l.pct) + "%" : "no rule") + "</span><span>" +
        (i === d.winner ? '<span class="sc-tag ok">' + ico("check") + "applied</span>" : l.found ? '<span class="sc-tag">ignored</span>' : "") + "</span></div>";
    }).join("");
    var bonusHtml = b.exists ?
      '<div class="sc-kv"><div><div class="sc-k">Free quantity</div><div class="sc-mono">' + num(b.qty) + '</div></div><div><div class="sc-k">From</div><div class="sc-mono">' + num(b.min) + ' ordered</div></div>' +
      '<div><div class="sc-k">Additional discount</div><div class="sc-mono">' + num(b.add) + '%</div></div><div><div class="sc-k">MOH discount</div><div class="sc-mono">' + num(b.moh) + "% " + (d.gov ? '<span class="sc-tag warn">Government</span>' : '<span class="sc-faint">Government only</span>') + "</div></div></div>" +
      '<div class="sc-note' + (b.found ? "" : " warn") + '" style="margin-top:10px">' + (b.found ? "The bonus applies: a free line is added when the order is created." : "Minimum quantity not reached: order at least " + num(b.min) + " to get the bonus.") + "</div>"
      : '<div class="sc-muted">No bonus rule for this customer and item.</div>';
    return head +
      '<div class="sc-cols"><div class="sc-stack">' +
      '<div class="sc-card"><div class="sc-card-h"><h2>Which discount rule wins</h2><span>priority: ' + esc(d.priorityMode) + '</span></div><div class="sc-card-b"><div class="sc-ladder">' + ladder + "</div>" +
      '<div class="sc-note" style="margin-top:10px">' + (d.winner >= 0 ? "Several rules can match. The rule marked as applied is used on the line." : "No GNC rule: the standard price list discount stays on the line.") + "</div></div></div>" +
      '<div class="sc-card"><div class="sc-card-h"><h2>Bonus rule</h2><span>Bonus Setup</span></div><div class="sc-card-b">' + bonusHtml + "</div></div>" +
      '</div><div class="sc-stack">' +
      '<div class="sc-card"><div class="sc-card-h"><h2>Line discount</h2><span>added together</span></div><div class="sc-card-b"><div class="sc-calc">' +
      '<span class="p"><b>' + num(d.base) + '%</b><span>discount rule</span></span><span class="op">+</span><span class="p"><b>' + num(d.add) + '%</b><span>additional</span></span><span class="op">+</span>' +
      '<span class="p"><b>' + num(d.moh) + '%</b><span>MOH</span></span><span class="op">=</span><span class="p res"><b>' + num(d.total) + "%</b><span>on the line</span></span></div></div></div>" +
      '<div class="sc-card"><div class="sc-card-h"><h2>Result</h2><span>' + esc(d.customerName) + " · " + esc(d.sector || "no sector") + '</span></div><div class="sc-card-b">' +
      '<div class="sc-big sc-mono">' + amt(d.net) + ' <span class="sc-faint" style="font-size:14px;font-weight:400">' + esc(d.currency) + "</span></div>" +
      '<div class="sc-note">' + num(d.qty) + " × " + amt(d.unitPrice) + " = " + amt(d.gross) + " " + esc(d.currency) + " before discount</div>" +
      '<div class="sc-scroll" style="margin-top:12px"><table class="sc-t"><thead><tr><th>Line</th><th class="r">Qty</th><th class="r">Disc.</th><th class="r">Amount</th></tr></thead><tbody>' +
      "<tr><td>" + esc(d.itemNo + " · " + d.itemName) + '</td><td class="r sc-mono">' + num(d.qty) + '</td><td class="r sc-mono">' + num(d.total) + '%</td><td class="r sc-mono">' + amt(d.net) + "</td></tr>" +
      (b.found ? '<tr class="bonus"><td>' + ico("gift") + ' Bonus · same item</td><td class="r sc-mono">' + num(b.qty) + '</td><td class="r sc-mono">100%</td><td class="r sc-mono">0</td></tr>' : "") +
      '</tbody></table></div><div class="sc-note" style="margin-top:8px">Unit price from the item card. Price lists are not included in the simulation.</div></div></div>' +
      "</div></div>";
  }

  return { init: init, render: render };
})();

// Appelée par BC (procédure Render du control add-in)
function Render(view, data) { GNCSalesScreens.render(view, data); }
