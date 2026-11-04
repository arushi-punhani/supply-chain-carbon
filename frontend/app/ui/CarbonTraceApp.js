"use client";

import { useEffect, useMemo, useState } from "react";

const API = (process.env.NEXT_PUBLIC_API_BASE_URL || "http://localhost:4000/api").replace(/\/$/, "");
const NAV = [
  ["overview", "Overview", "▦"], ["initiatives", "Reduction initiatives", "↗"],
  ["products", "Product footprint", "◈"], ["shipments", "Shipments", "⇢"],
  ["suppliers", "Suppliers", "◎"], ["credits", "Carbon credits", "✳"]
];
const STATUS = ["PLANNED", "IN_PROGRESS", "COMPLETED", "ON_HOLD"];
const fmt = (value) => Number(value || 0).toLocaleString("en-IN", { maximumFractionDigits: 1 });
const kg = (value) => `${fmt(value)} kg`;
const dateLabel = (value) => value ? new Date(value).toLocaleDateString("en-IN", { day: "2-digit", month: "short", year: "numeric" }) : "—";

async function api(path, options = {}) {
  const response = await fetch(`${API}${path}`, {
    ...options,
    credentials: "include",
    headers: { ...(options.body ? { "Content-Type": "application/json" } : {}), ...options.headers }
  });
  if (response.status === 204) return null;
  const body = await response.json().catch(() => ({}));
  if (!response.ok) throw new Error(body.error || `Request failed (${response.status})`);
  return body;
}

function Metric({ label, value, note, icon }) {
  return <article className="metric"><div className="metric-label">{label}<span>{icon}</span></div><strong>{value}</strong><small>{note}</small></article>;
}

function PanelTitle({ eyebrow, title, detail, action }) {
  return <div className="panel-title"><div><span className="eyebrow">{eyebrow}</span><h2>{title}</h2>{detail && <p>{detail}</p>}</div>{action}</div>;
}

function Empty({ children = "No records found." }) {
  return <div className="empty"><span>∅</span><p>{children}</p></div>;
}

function CarbonTraceApp() {
  const [user, setUser] = useState(null);
  const [booting, setBooting] = useState(true);
  const [view, setView] = useState("overview");
  const [data, setData] = useState({});
  const [suppliers, setSuppliers] = useState([]);
  const [products, setProducts] = useState([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");
  const [notice, setNotice] = useState("");
  const [search, setSearch] = useState("");
  const [loginEmail, setLoginEmail] = useState("");
  const [loginPassword, setLoginPassword] = useState("");
  const [initiative, setInitiative] = useState(null);

  async function loadPage(nextView = view) {
    if (!user) return;
    setLoading(true); setError(""); setSearch("");
    try {
      if (nextView === "overview") { const result = await api("/dashboard"); setData((prev) => ({ ...prev, dashboard: result })); }
      if (nextView === "products") { const result = await api("/products"); setData((prev) => ({ ...prev, products: result })); }
      if (nextView === "shipments") { const result = await api("/shipments"); setData((prev) => ({ ...prev, shipments: result })); }
      if (nextView === "suppliers") { const result = await api("/suppliers"); setData((prev) => ({ ...prev, suppliers: result })); }
      if (nextView === "credits") { const result = await api("/credits"); setData((prev) => ({ ...prev, credits: result })); }
      if (nextView === "initiatives") {
        const [rows, supplierRows, productRows] = await Promise.all([api("/initiatives"), api("/suppliers"), api("/products")]);
        setData((prev) => ({ ...prev, initiatives: rows })); setSuppliers(supplierRows); setProducts(productRows);
      }
      if (nextView === "audit") { const result = await api("/audit?limit=100"); setData((prev) => ({ ...prev, audit: result })); }
    } catch (loadError) { setError(loadError.message); }
    finally { setLoading(false); }
  }

  useEffect(() => {
    api("/auth/me").then((result) => setUser(result.user)).catch(() => {}).finally(() => setBooting(false));
  }, []);

  useEffect(() => { if (user) loadPage(view); }, [user, view]); // eslint-disable-line react-hooks/exhaustive-deps

  async function signIn(event) {
    event.preventDefault(); setError(""); setLoading(true);
    try { const result = await api("/auth/login", { method: "POST", body: JSON.stringify({ email: loginEmail, password: loginPassword }) }); setUser(result.user); setLoginPassword(""); }
    catch (loginError) { setError(loginError.message); }
    finally { setLoading(false); }
  }

  async function signOut() {
    try { await api("/auth/logout", { method: "POST" }); } catch { /* the session still expires server-side */ }
    setUser(null); setData({}); setView("overview");
  }

  async function saveInitiative(event) {
    event.preventDefault(); setError(""); setNotice("");
    const formElement = event.currentTarget;
    const form = new FormData(formElement);
    const payload = Object.fromEntries(form.entries());
    payload.baselineKg = Number(payload.baselineKg); payload.targetReductionKg = Number(payload.targetReductionKg);
    try {
      const editingId = initiative?.initiative_id;
      const result = await api(editingId ? `/initiatives/${editingId}` : "/initiatives", {
        method: editingId ? "PUT" : "POST", body: JSON.stringify(payload)
      });
      setInitiative(null); formElement.reset();
      setNotice(result.auditPending ? "Saved. The audit event is queued and will sync when MongoDB is available." : editingId ? "Initiative updated and audit event recorded." : "Initiative created and audit event recorded.");
      await loadPage("initiatives");
    } catch (saveError) { setError(saveError.message); }
  }

  async function deleteInitiative(row) {
    if (!window.confirm(`Delete “${row.title}”? This action is recorded in the audit history.`)) return;
    setError(""); setNotice("");
    try {
      const result = await api(`/initiatives/${row.initiative_id}`, { method: "DELETE" });
      setNotice(result.auditPending ? "Deleted. The audit event is queued for MongoDB." : "Initiative deleted and audit event recorded.");
      await loadPage("initiatives");
    } catch (deleteError) { setError(deleteError.message); }
  }

  const filteredProducts = useMemo(() => (data.products || []).filter((row) => `${row.product_name} ${row.category || ""}`.toLowerCase().includes(search.toLowerCase())), [data.products, search]);
  const filteredSuppliers = useMemo(() => (data.suppliers || []).filter((row) => `${row.supplier_name} ${row.country || ""}`.toLowerCase().includes(search.toLowerCase())), [data.suppliers, search]);
  const activeTitle = [...NAV, ["audit", "Audit history", "⌁"]].find(([id]) => id === view)?.[1] || "Supply chain overview";

  if (booting) return <main className="boot"><div className="brand-mark">C</div><p>Preparing CarbonTrace…</p></main>;
  if (!user) return <main className="login-shell">
    <section className="login-art"><a className="brand" href="#"><span className="brand-mark">C</span><span>carbontrace<small>SUPPLY CHAIN DECARBONIZATION</small></span></a>
      <div className="login-message"><span className="eyebrow">CARBON INTELLIGENCE / LEVEL 3 DBMS</span><h1>Make emissions visible.<br/><em>Make reductions real.</em></h1><p>Follow the carbon impact from product and shipment records to measurable supplier reduction plans.</p>
        <div className="login-proof"><div><b>01</b><span>Relational footprint</span></div><div><b>02</b><span>Actionable reduction</span></div><div><b>03</b><span>Auditable change history</span></div></div></div>
      <div className="login-footer">MYSQL + MONGODB <i/> DATA THAT CAN BE EXPLAINED</div>
    </section>
    <section className="login-card"><div className="login-form-wrap"><span className="eyebrow">TEAM WORKSPACE</span><h2>Welcome back</h2><p>Sign in with your CarbonTrace account.</p>
      <form onSubmit={signIn} className="form-stack"><label>Email<input type="email" autoComplete="username" value={loginEmail} onChange={(e) => setLoginEmail(e.target.value)} required maxLength={190}/></label><label>Password<input type="password" autoComplete="current-password" value={loginPassword} onChange={(e) => setLoginPassword(e.target.value)} required maxLength={256}/></label>
        {error && <div className="alert error-alert" role="alert">{error}</div>}<button className="primary-btn full-btn" disabled={loading}>{loading ? "Signing in…" : "Sign in securely"}<span>→</span></button></form>
      <div className="login-help">Accounts are created by the project administrator using the backend setup script. There are no built-in demo passwords.</div>
    </div></section>
  </main>;

  const dashboard = data.dashboard;
  return <div className="app-shell">
    <aside className="sidebar"><a className="brand" href="#" onClick={(e) => { e.preventDefault(); setView("overview"); }}><span className="brand-mark">C</span><span>carbontrace<small>SUPPLY CHAIN INTELLIGENCE</small></span></a>
      <div className="nav-label">WORKSPACE</div>{NAV.map(([id, label, icon]) => <button key={id} className={`nav-item ${view === id ? "active" : ""}`} onClick={() => setView(id)}><span>{icon}</span>{label}</button>)}
      {user.role === "admin" && <><div className="nav-label nav-admin-label">GOVERNANCE</div><button className={`nav-item ${view === "audit" ? "active" : ""}`} onClick={() => setView("audit")}><span>⌁</span>Audit history</button></>}
      <div className="sidebar-bottom"><div className="status-dot ok"/><div><strong>{user.displayName}</strong><small>{user.role === "admin" ? "Administrator" : "Analyst"}</small></div><button className="signout" onClick={signOut} aria-label="Sign out" title="Sign out">↗</button></div>
    </aside>
    <main className="main"><header className="topbar"><div><div className="eyebrow">SUSTAINABILITY CONSOLE / {view === "overview" ? "01" : "02"}</div><h1>{activeTitle}</h1></div><div className="top-actions"><span className="role-pill">{user.role.toUpperCase()}</span><button className="refresh" onClick={() => loadPage()} disabled={loading}>↻ Refresh</button></div></header>
      {error && <div className="alert error-alert" role="alert">{error}</div>}{notice && <div className="alert success-alert" role="status">{notice}</div>}
      {loading ? <div className="loading"><span className="spinner"/>Loading verified database records…</div> : <>
        {view === "overview" && <Overview dashboard={dashboard} />}
        {view === "products" && <Products rows={filteredProducts} search={search} setSearch={setSearch}/>}
        {view === "suppliers" && <Suppliers rows={filteredSuppliers} search={search} setSearch={setSearch}/>}
        {view === "shipments" && <Shipments rows={data.shipments || []}/>}
        {view === "credits" && <Credits rows={data.credits || []}/>}
        {view === "initiatives" && <Initiatives rows={data.initiatives || []} suppliers={suppliers} products={products} user={user} editing={initiative} setEditing={setInitiative} onSave={saveInitiative} onDelete={deleteInitiative}/>}
        {view === "audit" && <Audit rows={data.audit || []}/>}
      </>}
      <footer className="main-footer"><span>CARBONTRACE</span><span>Recorded emissions and approved reduction targets · MySQL + MongoDB</span></footer>
    </main>
  </div>;
}

function Overview({ dashboard }) {
  if (!dashboard) return <div className="empty-state">Dashboard data will appear after records load.</div>;
  const { counts, scopes, products, initiatives } = dashboard;
  const max = Math.max(1, ...scopes.map((s) => Number(s.total)));
  return <>
    <section className="hero"><div><div className="eyebrow">SUPPLY CHAIN / CARBON HOTSPOTS</div><h2>Turn your carbon data into a reduction plan.</h2><p>Connect the footprint you record to supplier and product initiatives with clear owners, targets, and audit history.</p></div><div className="hero-total"><small>TOTAL RECORDED</small><strong>{fmt(counts.totalEmissionsKg)}<i>kg CO₂e</i></strong><span>Across {fmt(counts.products)} tracked products</span></div></section>
    <section className="metrics"><Metric label="Recorded emissions" value={kg(counts.totalEmissionsKg)} note="Sum of emission records" icon="↗"/><Metric label="Suppliers" value={fmt(counts.suppliers)} note="Supplier register" icon="◎"/><Metric label="Shipments" value={fmt(counts.shipments)} note="Logistics records" icon="⇢"/><Metric label="Planned reductions" value={kg(initiatives.planned_reduction_kg)} note={`${fmt(initiatives.count)} tracked initiatives`} icon="⌁"/></section>
    <div className="overview-grid"><section className="panel"><PanelTitle eyebrow="EMISSIONS / BY SCOPE" title="Where the footprint sits" detail="Actual emission entries grouped by their recorded scope."/>
      {scopes.length ? <div className="scope-list">{scopes.map((row, i) => <div className="scope-row" key={row.scope}><div className="scope-meta"><span>{row.scope}</span><b>{kg(row.total)}</b></div><div className="bar"><span style={{ width: `${Math.max(Number(row.total) > 0 ? 3 : 0, Number(row.total) / max * 100)}%`, background: ["#b9f36b", "#67d9aa", "#84bdac", "#d2cd87"][i % 4] }}/></div></div>)}</div> : <Empty>No emissions are recorded in MySQL yet.</Empty>}
      <div className="data-note">Scope totals use the <code>emission</code> table. Calculated material estimates remain separate to avoid double counting.</div></section>
      <section className="panel"><PanelTitle eyebrow="PRODUCT HOTSPOTS" title="Highest recorded footprints" detail="Use the ranked list to focus reduction work."/>
        {products.length ? <div className="rank-list">{products.slice(0, 5).map((p, i) => <div className="rank-row" key={p.product_id}><span className="rank-index">0{i + 1}</span><div><b>{p.product_name}</b><small>{p.category || "Uncategorised"}</small></div><strong>{kg(p.total_emissions_kg_co2e)}</strong></div>)}</div> : <Empty>No product emission records found.</Empty>}</section></div>
  </>;
}

function Products({ rows, search, setSearch }) {
  return <section className="panel"><PanelTitle eyebrow="CATALOGUE / PRODUCT CARBON" title="Product footprint register" detail="Recorded emissions grouped by product. Search by name or category."/>
    <div className="toolbar"><input className="search" placeholder="Search products…" value={search} onChange={(e) => setSearch(e.target.value)} aria-label="Search products"/><span>{rows.length} results</span></div>
    {rows.length ? <div className="table-scroll"><table><thead><tr><th>PRODUCT</th><th>CATEGORY</th><th>DESCRIPTION</th><th className="align-right">RECORDED CO₂e</th></tr></thead><tbody>{rows.map((p) => <tr key={p.product_id}><td className="name-cell">{p.product_name}<small>ID {p.product_id}</small></td><td>{p.category || "—"}</td><td>{p.description || "—"}</td><td className="align-right number-cell">{kg(p.total_emissions_kg_co2e)}</td></tr>)}</tbody></table></div> : <Empty>No products match the current search.</Empty>}
  </section>;
}

function Suppliers({ rows, search, setSearch }) {
  return <section className="panel"><PanelTitle eyebrow="PARTNERS / SUPPLIER NETWORK" title="Supplier directory" detail="Suppliers from the MySQL project schema."/>
    <div className="toolbar"><input className="search" placeholder="Search suppliers…" value={search} onChange={(e) => setSearch(e.target.value)} aria-label="Search suppliers"/><span>{rows.length} results</span></div>
    {rows.length ? <div className="table-scroll"><table><thead><tr><th>SUPPLIER</th><th>COUNTRY</th><th>CONTACT</th><th>ID</th></tr></thead><tbody>{rows.map((s) => <tr key={s.supplier_id}><td className="name-cell">{s.supplier_name}</td><td>{s.country || "—"}</td><td>{s.contact_info || "—"}</td><td className="number-cell">{s.supplier_id}</td></tr>)}</tbody></table></div> : <Empty>No suppliers match the current search.</Empty>}
    <div className="data-note">Supplier ESG scores are not in the source schema, so no scores are inferred or invented.</div>
  </section>;
}

function Shipments({ rows }) {
  return <section className="panel"><PanelTitle eyebrow="LOGISTICS / TRANSPORT ESTIMATES" title="Shipment ledger" detail="Estimates use the matching transport factor and shipment weight and distance."/>
    {rows.length ? <div className="table-scroll"><table><thead><tr><th>SHIPMENT</th><th>SUPPLIER / FACTORY</th><th>MODE</th><th>DISTANCE</th><th>WEIGHT</th><th className="align-right">CALCULATED CO₂e</th></tr></thead><tbody>{rows.map((s) => <tr key={s.shipment_id}><td className="name-cell">#{s.shipment_id}<small>{dateLabel(s.shipment_date)}</small></td><td>{s.supplier_name}<small className="subline">{s.factory_name}</small></td><td><span className="status-tag">{s.transport_mode || "Unknown"}</span></td><td>{fmt(s.distance_km)} km</td><td>{fmt(s.weight_kg)} kg</td><td className="align-right">{s.calculated_emissions_kg_co2e == null ? <span className="warn-tag">Factor missing</span> : <span className="number-cell">{kg(s.calculated_emissions_kg_co2e)}</span>}</td></tr>)}</tbody></table></div> : <Empty>No shipment records found.</Empty>}
    <div className="data-note">A missing factor is shown as “Factor missing”; the supplied data has a Truck factor, not a Ship factor.</div>
  </section>;
}

function Credits({ rows }) {
  return <section className="panel"><PanelTitle eyebrow="OFFSET INVENTORY / REFERENCE" title="Carbon credit register" detail="Inventory status from the source schema. Credits are not treated as reductions to measured emissions."/>
    {rows.length ? <div className="table-scroll"><table><thead><tr><th>CREDIT</th><th>AMOUNT</th><th>STATUS</th><th>CLAIMED BY</th><th>DATE</th></tr></thead><tbody>{rows.map((c) => <tr key={c.credit_id}><td className="name-cell">#{c.credit_id}</td><td>{kg(c.amount_kg_co2e)}</td><td><span className={`status-tag ${c.status === "AVAILABLE" ? "status-good" : ""}`}>{c.status}</span></td><td>{c.claimed_by || "—"}</td><td>{dateLabel(c.credit_date)}</td></tr>)}</tbody></table></div> : <Empty>No carbon credits in the database.</Empty>}
  </section>;
}

function Initiatives({ rows, suppliers, products, user, editing, setEditing, onSave, onDelete }) {
  const canWrite = user.role === "admin";
  return <div className="initiative-layout"><section className="panel"><PanelTitle eyebrow="ACTION REGISTER / SQL TRANSACTIONS" title="Reduction initiatives" detail="Create, update, and retire measurable reduction plans. Changes are appended to the MongoDB audit log."/>
    {rows.length ? <div className="initiative-list">{rows.map((row) => <article className="initiative-card" key={row.initiative_id}><div className="initiative-card-head"><span className={`status-tag status-${row.status.toLowerCase()}`}>{row.status.replaceAll("_", " ")}</span><span className="initiative-id">INIT-{String(row.initiative_id).padStart(3, "0")}</span></div><h3>{row.title}</h3><p>{row.description || "No description provided."}</p><div className="target-line"><div><small>TARGET REDUCTION</small><b>{kg(row.target_reduction_kg_co2e)}</b></div><div><small>BASELINE</small><b>{kg(row.baseline_kg_co2e)}</b></div><div><small>TARGET</small><b>{fmt(row.target_reduction_percent)}%</b></div></div><div className="initiative-foot"><span>{row.supplier_name || row.product_name || "Supply chain"}</span><span>Due {dateLabel(row.due_date)}</span></div>
      {canWrite && <div className="card-actions"><button className="quiet-btn" onClick={() => setEditing(row)}>Edit plan</button><button className="danger-btn" onClick={() => onDelete(row)}>Delete</button></div>}</article>)}</div> : <Empty>No reduction initiatives yet. Create the first plan to connect carbon measurements with action.</Empty>}
    </section>
    {canWrite && <section className="panel form-panel"><PanelTitle eyebrow="ADMIN / WRITE ACCESS" title={editing ? "Edit initiative" : "New initiative"} detail="Inputs are checked in the API and again by MySQL constraints."/>
      <form className="initiative-form" onSubmit={onSave} key={editing?.initiative_id || "new"}>
        <label>Initiative title<input name="title" required maxLength={120} defaultValue={editing?.title || ""} placeholder="e.g. Renewable electricity at assembly site"/></label>
        <label>What will change?<textarea name="description" maxLength={500} rows={3} defaultValue={editing?.description || ""} placeholder="Describe the action and how reduction will be measured."/></label>
        <div className="two-fields"><label>Baseline (kg CO₂e)<input type="number" name="baselineKg" min="0.001" max="1000000000" step="0.001" required defaultValue={editing?.baseline_kg_co2e ?? ""}/></label><label>Target reduction (kg)<input type="number" name="targetReductionKg" min="0.001" max="1000000000" step="0.001" required defaultValue={editing?.target_reduction_kg_co2e ?? ""}/></label></div>
        <div className="two-fields"><label>Supplier (optional)<select name="supplierId" defaultValue={editing?.supplier_id ?? ""}><option value="">Choose supplier</option>{suppliers.map((s) => <option key={s.supplier_id} value={s.supplier_id}>{s.supplier_name}</option>)}</select></label><label>Product (optional)<select name="productId" defaultValue={editing?.product_id ?? ""}><option value="">Choose product</option>{products.map((p) => <option key={p.product_id} value={p.product_id}>{p.product_name}</option>)}</select></label></div>
        <div className="two-fields"><label>Status<select name="status" defaultValue={editing?.status || "PLANNED"}>{STATUS.map((s) => <option key={s} value={s}>{s.replaceAll("_", " ")}</option>)}</select></label><label>Target date<input type="date" name="dueDate" defaultValue={editing?.due_date ? String(editing.due_date).slice(0, 10) : ""}/></label></div>
        <p className="form-hint">Link the plan to at least one supplier or product. The target cannot exceed its baseline.</p>
        <div className="form-actions"><button className="primary-btn" type="submit">{editing ? "Save changes" : "Create initiative"}<span>→</span></button>{editing && <button className="quiet-btn" type="button" onClick={() => setEditing(null)}>Cancel</button>}</div>
      </form>
    </section>}
  </div>;
}

function Audit({ rows }) {
  return <section className="panel"><PanelTitle eyebrow="MONGODB / APPEND-ONLY RECORDS" title="Audit history" detail="Latest initiative changes, stored as documents and retrieved with a MongoDB aggregation pipeline."/>
    {rows.length ? <div className="audit-list">{rows.map((row) => <article key={row.eventId} className="audit-row"><span className={`audit-icon audit-${row.action}`}>{row.action === "created" ? "+" : row.action === "deleted" ? "−" : "↻"}</span><div><b>{row.action} initiative #{row.entityId}</b><p>{row.details?.title || row.details?.after?.title || "Initiative record changed"}</p><small>{row.actor?.displayName || row.actor?.email} · {row.actor?.role}</small></div><time>{dateLabel(row.occurredAt)}</time></article>)}</div> : <Empty>No audit events are available yet. Initiative changes will appear here.</Empty>}
    <div className="data-note">A MySQL outbox queues events if MongoDB is unavailable; the page retries delivery before loading history.</div>
  </section>;
}

export default CarbonTraceApp;
