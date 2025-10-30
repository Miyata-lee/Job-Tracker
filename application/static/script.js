/* ============================================
   JobTracker Frontend Script (single index + dashboard)
   - /auth: Login + Sign Up tabs (one visible at a time)
   - /dashboard: CRUD + stats with icons
   ============================================ */

/* ------------- Utilities ------------- */
function $(sel, root=document){ return root.querySelector(sel); }
function $all(sel, root=document){ return Array.from(root.querySelectorAll(sel)); }
function escapeHtml(s){
  return String(s ?? '').replace(/&/g,'&amp;').replace(/</g,'&lt;')
    .replace(/>/g,'&gt;').replace(/"/g,'&quot;').replace(/'/g,'&#39;');
}
function fmtDateSafe(s){
  if(!s) return '';
  const opts = { day:'2-digit', month:'short', year:'numeric' };
  if(/^\d{4}-\d{2}-\d{2}$/.test(s)){
    const [y,m,d] = s.split('-').map(Number);
    return new Date(Date.UTC(y,m-1,d)).toLocaleDateString(undefined, opts);
  }
  const dt = new Date(s);
  return isNaN(dt) ? s : dt.toLocaleDateString(undefined, opts);
}

/* ------------- AUTH: /auth tabs (one visible) ------------- */
function initAuthTabs(){
  const tabLogin  = $('#tabLogin');
  const tabSignup = $('#tabSignup');
  const loginPane = $('#loginPane');
  const signupPane= $('#signupPane');
  const toSignup  = $('#toSignup');
  const toLogin   = $('#toLogin');
  const loginForm = $('#loginForm');
  const signupForm= $('#signupForm');
  const loginError= $('#loginError');
  const loginOk   = $('#loginOk');
  const signupError=$('#signupError');
  const signupOk  = $('#signupOk');

  if(!loginPane || !signupPane) return; // Not on /auth

  function clearAlerts(){
    [loginError,loginOk,signupError,signupOk].forEach(e=>{
      if(e){ e.style.display='none'; e.textContent=''; }
    });
  }

  function show(which){
    if(which==='signup'){
      signupPane.classList.remove('hidden');
      loginPane.classList.add('hidden');
      tabSignup?.classList.add('active');
      tabLogin?.classList.remove('active');
      signupForm?.reset();
      setTimeout(()=> $('#signup_username')?.focus(), 20);
    }else{
      loginPane.classList.remove('hidden');
      signupPane.classList.add('hidden');
      tabLogin?.classList.add('active');
      tabSignup?.classList.remove('active');
      loginForm?.reset();
      setTimeout(()=> $('#login_username')?.focus(), 20);
    }
    clearAlerts();
  }

  // Default from URL (?view=signup)
  const view = new URLSearchParams(location.search).get('view');
  show(view==='signup' ? 'signup' : 'login');

  // Toggle handlers
  tabLogin?.addEventListener('click', ()=>show('login'));
  tabSignup?.addEventListener('click', ()=>show('signup'));
  toSignup?.addEventListener('click', ()=>show('signup'));
  toLogin?.addEventListener('click', ()=>show('login'));

  // Login submit
  loginForm?.addEventListener('submit', async (e)=>{
    e.preventDefault(); clearAlerts();
    try{
      const username = $('#login_username').value.trim();
      const password = $('#login_password').value;
      const res = await fetch('/api/login', {
        method:'POST',
        headers:{'Content-Type':'application/json'},
        body: JSON.stringify({username,password})
      });
      const data = await res.json();
      if(data.success){
        loginOk.textContent = 'Login successful! Redirecting...';
        loginOk.style.display = 'block';
        setTimeout(()=> location.href='/dashboard', 800);
      }else{
        loginError.textContent = data.message || 'Login failed';
        loginError.style.display = 'block';
      }
    }catch(_){
      loginError.textContent = 'Network error. Please try again.';
      loginError.style.display = 'block';
    }
  });

  // Signup submit
  signupForm?.addEventListener('submit', async (e)=>{
    e.preventDefault(); clearAlerts();
    const username = $('#signup_username').value.trim();
    const email    = $('#signup_email').value.trim();
    const password = $('#signup_password').value;
    const confirm  = $('#signup_confirm').value;

    if(password !== confirm){
      signupError.textContent = 'Passwords do not match';
      signupError.style.display = 'block';
      return;
    }
    if(password.length < 6){
      signupError.textContent = 'Password must be at least 6 characters';
      signupError.style.display = 'block';
      return;
    }

    try{
      const res = await fetch('/api/signup', {
        method:'POST',
        headers:{'Content-Type':'application/json'},
        body: JSON.stringify({username,email,password})
      });
      const data = await res.json();
      if(data.success){
        signupOk.textContent = 'Account created! Switching to login...';
        signupOk.style.display = 'block';
        setTimeout(()=> show('login'), 900);
      }else{
        signupError.textContent = data.message || 'Signup failed';
        signupError.style.display = 'block';
      }
    }catch(_){
      signupError.textContent = 'Network error. Please try again.';
      signupError.style.display = 'block';
    }
  });
}

/* ------------- DASHBOARD: jobs + stats ------------- */
let allJobs = [];
let currentFilter = 'all';

function statusChip(status){
  const s = (status||'').toLowerCase();
  if(s==='applied')   return {cls:'applied',   txt:'APPLIED'};
  if(s==='interview') return {cls:'interview', txt:'INTERVIEW'};
  if(s==='offer')     return {cls:'offer',     txt:'OFFER'};
  if(s==='rejected')  return {cls:'rejected',  txt:'REJECTED'};
  return {cls:'applied',txt:status||'STATUS'};
}

async function loadJobs(){
  const host = $('#jobsList'); if(!host) return;
  try{
    const res = await fetch('/api/jobs');
    const data = await res.json();
    if(data.success){
      allJobs = data.jobs || [];
      renderJobs(allJobs);
    }
  }catch(_){
    host.innerHTML = `<div class="empty-dark"><p><i class="fas fa-triangle-exclamation"></i> Error loading jobs</p></div>`;
  }
}

async function loadStats(){
  if(!$('#sApplied')) return;
  try{
    const res = await fetch('/api/stats');
    const data = await res.json();
    if(data.success){
      const by = (data.by_status||[]).reduce((a,s)=>{a[s.status]=s.count;return a}, {});
      $('#sApplied').textContent   = by['Applied']   || 0;
      $('#sInterview').textContent = by['Interview'] || 0;
      $('#sOffer').textContent     = by['Offer']     || 0;
      $('#sRejected').textContent  = by['Rejected']  || 0;
    }
  }catch(_){}
}

function renderJobs(list){
  const host = $('#jobsList');
  if(!list.length){
    host.innerHTML = `<div class="empty-dark"><p><i class="fas fa-inbox"></i> No applications found</p></div>`;
    return;
  }
  host.innerHTML = list.map(job=>{
    const chip = statusChip(job.status);
    return `
      <article class="job-card">
        <div class="jobcard-top">
          <div>
            <div class="job-title">${escapeHtml(job.position)}</div>
            <div class="job-company">${escapeHtml(job.company_name)}</div>
          </div>
          <span class="status-badge ${chip.cls}">${chip.txt}</span>
        </div>
        <div class="job-meta">
          <div><i class="fas fa-calendar"></i> ${fmtDateSafe(job.date_applied)}</div>
          <div><i class="fas fa-building"></i> ${escapeHtml(job.company_name)}</div>
        </div>
        ${job.notes ? `<div style="color:#c7d1db;margin-top:.35rem"><i class="fas fa-note-sticky"></i> ${escapeHtml(job.notes)}</div>` : ''}
        <div class="actions">
          <button class="btn-sm edit"   onclick="openEditModal(${job.id})"><i class="fas fa-pen"></i> Edit</button>
          <button class="btn-sm delete" onclick="deleteJob(${job.id})"><i class="fas fa-trash"></i> Delete</button>
        </div>
      </article>
    `;
  }).join('');
}

function filterByStatus(status, ev){
  $all('.chip-dark').forEach(b=>b.classList.remove('active'));
  ev.currentTarget.classList.add('active');
  currentFilter = status;
  filterJobs();
}

function filterJobs(){
  const q = ($('#searchInput')?.value || '').toLowerCase();
  let list = [...allJobs];
  if(currentFilter!=='all') list = list.filter(j=> j.status === currentFilter);
  list = list.filter(j => j.company_name.toLowerCase().includes(q) || j.position.toLowerCase().includes(q));
  renderJobs(list);
}

/* ------------- Modals: Add / Edit ------------- */
function openAddModal(){
  $('#addJobForm').reset();
  const d = $('#date_applied'); if(d) d.valueAsDate = new Date();
  $('#modalBackdrop').classList.add('active');
  $('#addJobModal').classList.add('active');
  setTimeout(()=> $('#company_name')?.focus(), 20);
  document.addEventListener('keydown', escToCloseAdd);
}
function closeAddModal(){
  $('#modalBackdrop').classList.remove('active');
  $('#addJobModal').classList.remove('active');
  document.removeEventListener('keydown', escToCloseAdd);
}
function escToCloseAdd(e){ if(e.key==='Escape') closeAddModal(); }

$('#addJobForm')?.addEventListener('submit', async (e)=>{
  e.preventDefault();
  const payload = {
    company_name: $('#company_name').value.trim(),
    position:     $('#position').value.trim(),
    status:       $('#status').value,
    date_applied: $('#date_applied').value,
    notes:        $('#notes').value.trim()
  };
  try{
    const res = await fetch('/api/jobs', {
      method:'POST', headers:{'Content-Type':'application/json'},
      body: JSON.stringify(payload)
    });
    const data = await res.json();
    if(data.success){
      closeAddModal(); await loadJobs(); await loadStats();
    }else{
      alert(data.message || 'Add failed');
    }
  }catch(_){ alert('Network error'); }
});

async function openEditModal(id){
  try{
    const res = await fetch(`/api/jobs/${id}`);
    const data = await res.json();
    if(!data.success) return alert(data.message || 'Load failed');
    const j = data.job;
    $('#edit_id').value            = j.id;
    $('#edit_company_name').value  = j.company_name || '';
    $('#edit_position').value      = j.position || '';
    $('#edit_status').value        = j.status || 'Applied';
    $('#edit_date_applied').value  = j.date_applied || '';
    $('#edit_notes').value         = j.notes || '';
    $('#editModalBackdrop').classList.add('active');
    $('#editJobModal').classList.add('active');
    setTimeout(()=> $('#edit_company_name')?.focus(), 20);
    document.addEventListener('keydown', escToCloseEdit);
  }catch(_){ alert('Network error'); }
}
function closeEditModal(){
  $('#editModalBackdrop').classList.remove('active');
  $('#editJobModal').classList.remove('active');
  document.removeEventListener('keydown', escToCloseEdit);
}
function escToCloseEdit(e){ if(e.key==='Escape') closeEditModal(); }

$('#editJobForm')?.addEventListener('submit', async (e)=>{
  e.preventDefault();
  const id = $('#edit_id').value;
  const payload = {
    company_name: $('#edit_company_name').value.trim(),
    position:     $('#edit_position').value.trim(),
    status:       $('#edit_status').value,
    date_applied: $('#edit_date_applied').value,
    notes:        $('#edit_notes').value.trim()
  };
  try{
    const res = await fetch(`/api/jobs/${id}`, {
      method:'PUT', headers:{'Content-Type':'application/json'},
      body: JSON.stringify(payload)
    });
    const data = await res.json();
    if(data.success){
      closeEditModal(); await loadJobs(); await loadStats();
    }else{
      alert(data.message || 'Update failed');
    }
  }catch(_){ alert('Network error'); }
});

/* ------------- Delete + Logout ------------- */
async function deleteJob(id){
  if(!confirm('Delete this application?')) return;
  try{
    const res = await fetch(`/api/jobs/${id}`, { method:'DELETE' });
    const data = await res.json();
    if(data.success){ await loadJobs(); await loadStats(); }
    else{ alert(data.message || 'Delete failed'); }
  }catch(_){ alert('Network error'); }
}

$('#logoutBtn')?.addEventListener('click', async ()=>{
  try{ await fetch('/api/logout', { method:'POST' }); location.href='/auth?view=login'; }
  catch(_){ alert('Logout error'); }
});

/* ------------- Boot ------------- */
document.addEventListener('DOMContentLoaded', ()=>{
  // Single-page /auth tabs
  initAuthTabs();

  // Dashboard
  if($('#jobsList')){
    loadJobs(); loadStats();
    $('#searchInput')?.addEventListener('input', filterJobs);
  }
});
