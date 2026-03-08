import React, { useState, useEffect, useRef } from 'react';
import { initializeApp } from 'firebase/app';
import { 
  getAuth, 
  signInAnonymously, 
  signInWithCustomToken, 
  onAuthStateChanged 
} from 'firebase/auth';
import { 
  getFirestore, 
  collection, 
  doc, 
  setDoc, 
  getDoc, 
  addDoc, 
  onSnapshot, 
  updateDoc, 
  query, 
  arrayUnion,
  timestamp
} from 'firebase/firestore';
import { 
  Layout, 
  Trophy, 
  Users, 
  MessageSquare, 
  Wallet, 
  ShieldCheck, 
  Settings, 
  Plus, 
  Zap, 
  Search, 
  Bell, 
  CreditCard, 
  User as UserIcon,
  LogOut,
  ChevronRight,
  ShieldAlert,
  Bot,
  Hash,
  Crown,
  Sword,
  Send
} from 'lucide-react';

// --- Firebase Configuration ---
const firebaseConfig = JSON.parse(__firebase_config);
const app = initializeApp(firebaseConfig);
const auth = getAuth(app);
const db = getFirestore(app);
const appId = typeof __app_id !== 'undefined' ? __app_id : 'elitestar-v1';

// --- Themes & Constants ---
const COLORS = {
  primary: '#FF6B00',
  bg: '#0A0A0A',
  card: 'rgba(255, 255, 255, 0.05)',
  glass: 'rgba(255, 107, 0, 0.1)',
  text: '#FFFFFF',
  textSecondary: '#A0A0A0'
};

const ROLES = {
  USER: 'user',
  ADMIN: 'admin',
  STAFF: 'staff'
};

// --- Components ---

const GlassCard = ({ children, className = "" }) => (
  <div className={`backdrop-blur-xl bg-white/5 border border-white/10 rounded-2xl shadow-2xl ${className}`}>
    {children}
  </div>
);

const App = () => {
  const [user, setUser] = useState(null);
  const [userData, setUserData] = useState(null);
  const [view, setView] = useState('dashboard'); // dashboard, tournaments, chat, wallet, admin, staff, profile
  const [loading, setLoading] = useState(true);
  const [matches, setMatches] = useState([]);
  const [activeChat, setActiveChat] = useState('general');

  // 1. Authentication Lifecycle
  useEffect(() => {
    const initAuth = async () => {
      try {
        if (typeof __initial_auth_token !== 'undefined' && __initial_auth_token) {
          await signInWithCustomToken(auth, __initial_auth_token);
        } else {
          await signInAnonymously(auth);
        }
      } catch (err) {
        console.error("Auth error:", err);
      }
    };
    initAuth();

    const unsubscribe = onAuthStateChanged(auth, (u) => {
      setUser(u);
      if (u) fetchUserData(u.uid);
      else setLoading(false);
    });
    return () => unsubscribe();
  }, []);

  // 2. Fetch/Sync User Profile
  const fetchUserData = async (uid) => {
    const userRef = doc(db, 'artifacts', appId, 'users', uid, 'profile', 'data');
    const snap = await getDoc(userRef);
    
    if (snap.exists()) {
      setUserData(snap.data());
    } else {
      const newUser = {
        uid: uid,
        elitestarId: `STAR-${Math.floor(1000 + Math.random() * 9000)}`,
        username: `Slayer_${Math.floor(Math.random() * 100)}`,
        ffId: '',
        ffName: '',
        level: 1,
        role: ROLES.USER, // Default role
        balance: 0,
        matchesPlayed: 0,
        wins: 0,
        joinedDate: new Date().toISOString(),
      };
      await setDoc(userRef, newUser);
      setUserData(newUser);
    }
    setLoading(false);
  };

  // 3. Real-time Matches Sync
  useEffect(() => {
    if (!user) return;
    const q = collection(db, 'artifacts', appId, 'public', 'data', 'matches');
    const unsubscribe = onSnapshot(q, (snapshot) => {
      const mList = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
      setMatches(mList);
    }, (err) => console.error("Firestore error:", err));
    return () => unsubscribe();
  }, [user]);

  // View Controller
  const renderView = () => {
    switch (view) {
      case 'dashboard': return <Dashboard userData={userData} matches={matches} setView={setView} />;
      case 'tournaments': return <Tournaments matches={matches} setView={setView} />;
      case 'chat': return <SocialChat userData={userData} activeChat={activeChat} setActiveChat={setActiveChat} />;
      case 'wallet': return <WalletView userData={userData} />;
      case 'admin': return <AdminPanel userData={userData} matches={matches} />;
      case 'staff': return <StaffPanel userData={userData} matches={matches} />;
      case 'profile': return <ProfileView userData={userData} setUserData={setUserData} />;
      default: return <Dashboard userData={userData} matches={matches} setView={setView} />;
    }
  };

  if (loading) return (
    <div className="min-h-screen bg-[#0A0A0A] flex items-center justify-center">
      <div className="animate-spin rounded-full h-12 w-12 border-t-2 border-[#FF6B00]"></div>
    </div>
  );

  return (
    <div className="min-h-screen bg-[#0A0A0A] text-white font-sans selection:bg-[#FF6B00]/30">
      {/* Top Navbar */}
      <nav className="fixed top-0 w-full z-50 px-4 py-3 bg-[#0A0A0A]/80 backdrop-blur-md border-b border-white/5 flex justify-between items-center">
        <div className="flex items-center gap-2" onClick={() => setView('dashboard')}>
          <div className="p-2 bg-[#FF6B00] rounded-lg">
            <Trophy size={20} className="text-black" strokeWidth={3} />
          </div>
          <span className="text-xl font-black tracking-tighter italic">ELITE<span className="text-[#FF6B00]">STAR</span></span>
        </div>
        
        <div className="flex items-center gap-4">
          <div className="hidden md:flex items-center gap-2 bg-white/5 px-3 py-1.5 rounded-full border border-white/10">
            <div className="w-2 h-2 rounded-full bg-green-500 animate-pulse"></div>
            <span className="text-xs font-medium text-gray-400">SERVER ONLINE</span>
          </div>
          <button className="relative p-2 text-gray-400 hover:text-white transition-colors">
            <Bell size={20} />
            <span className="absolute top-1 right-1 w-2 h-2 bg-[#FF6B00] rounded-full"></span>
          </button>
          <div 
            onClick={() => setView('profile')}
            className="w-10 h-10 rounded-xl bg-gradient-to-tr from-[#FF6B00] to-orange-400 p-[2px] cursor-pointer"
          >
            <div className="w-full h-full bg-[#0A0A0A] rounded-[10px] flex items-center justify-center">
              <UserIcon size={20} />
            </div>
          </div>
        </div>
      </nav>

      {/* Main Content Area */}
      <main className="pt-20 pb-24 px-4 max-w-7xl mx-auto">
        {renderView()}
      </main>

      {/* Bottom Navigation */}
      <nav className="fixed bottom-0 w-full z-50 px-4 py-4 bg-gradient-to-t from-black to-transparent pointer-events-none">
        <div className="max-w-md mx-auto pointer-events-auto">
          <GlassCard className="flex justify-around items-center p-2 rounded-3xl !bg-black/60 border-white/5">
            {[
              { id: 'dashboard', icon: Layout, label: 'Home' },
              { id: 'tournaments', icon: Sword, label: 'Play' },
              { id: 'chat', icon: MessageSquare, label: 'Chat' },
              { id: 'wallet', icon: Wallet, label: 'Wallet' },
              ...(userData?.role === ROLES.ADMIN ? [{ id: 'admin', icon: ShieldCheck, label: 'Admin' }] : []),
              ...(userData?.role === ROLES.STAFF ? [{ id: 'staff', icon: ShieldCheck, label: 'Staff' }] : []),
            ].map((item) => (
              <button
                key={item.id}
                onClick={() => setView(item.id)}
                className={`flex flex-col items-center gap-1 px-4 py-2 rounded-2xl transition-all ${view === item.id ? 'text-[#FF6B00] bg-white/5' : 'text-gray-500'}`}
              >
                <item.icon size={22} strokeWidth={view === item.id ? 2.5 : 2} />
                <span className="text-[10px] font-bold uppercase tracking-widest">{item.label}</span>
              </button>
            ))}
          </GlassCard>
        </div>
      </nav>

      {/* AI Assistant FAB */}
      <EliteBot />
    </div>
  );
};

// --- View: Dashboard ---
const Dashboard = ({ userData, matches, setView }) => {
  const ongoingMatches = matches.filter(m => m.status === 'open');
  
  return (
    <div className="space-y-6 animate-in fade-in slide-in-from-bottom-4 duration-700">
      {/* Welcome Header */}
      <div className="flex flex-col gap-1">
        <h1 className="text-3xl font-black">HELLO, {userData?.username.toUpperCase()}</h1>
        <p className="text-gray-400 text-sm font-medium">Ready to dominate the battlefield?</p>
      </div>

      {/* Stats Cards */}
      <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
        <GlassCard className="p-4 flex flex-col gap-1">
          <span className="text-[10px] text-gray-500 font-bold uppercase">Balance</span>
          <div className="flex items-center gap-1 text-[#FF6B00]">
             <span className="text-xl font-black">₹{userData?.balance || 0}</span>
          </div>
        </GlassCard>
        <GlassCard className="p-4 flex flex-col gap-1">
          <span className="text-[10px] text-gray-500 font-bold uppercase">ES-UID</span>
          <span className="text-xl font-black text-white">{userData?.elitestarId}</span>
        </GlassCard>
        <GlassCard className="p-4 flex flex-col gap-1">
          <span className="text-[10px] text-gray-500 font-bold uppercase">Matches</span>
          <span className="text-xl font-black text-white">{userData?.matchesPlayed}</span>
        </GlassCard>
        <GlassCard className="p-4 flex flex-col gap-1">
          <span className="text-[10px] text-gray-500 font-bold uppercase">Wins</span>
          <span className="text-xl font-black text-green-500">{userData?.wins}</span>
        </GlassCard>
      </div>

      {/* Featured Banner */}
      <div className="relative h-48 rounded-3xl overflow-hidden group cursor-pointer" onClick={() => setView('tournaments')}>
        <div className="absolute inset-0 bg-gradient-to-r from-black via-black/40 to-transparent z-10"></div>
        <img 
          src="https://images.unsplash.com/photo-1542751371-adc38448a05e?auto=format&fit=crop&q=80&w=1000" 
          className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-1000" 
          alt="FF Banner" 
        />
        <div className="absolute inset-0 z-20 p-8 flex flex-col justify-center gap-2">
          <div className="flex items-center gap-2 text-[#FF6B00] font-black text-xs tracking-widest uppercase">
            <Zap size={14} fill="#FF6B00" /> Season 12 Mega Tournament
          </div>
          <h2 className="text-4xl font-black italic">WIN ₹10,000+</h2>
          <button className="mt-2 bg-[#FF6B00] text-black text-xs font-black px-6 py-3 rounded-xl w-fit uppercase hover:scale-105 active:scale-95 transition-all">
            Register Now
          </button>
        </div>
      </div>

      {/* Live Tournaments Scroll */}
      <div className="space-y-4">
        <div className="flex justify-between items-end">
          <h3 className="text-lg font-black italic border-l-4 border-[#FF6B00] pl-3">ACTIVE TOURNAMENTS</h3>
          <button onClick={() => setView('tournaments')} className="text-xs font-bold text-[#FF6B00] hover:underline">VIEW ALL</button>
        </div>
        
        <div className="grid md:grid-cols-2 gap-4">
          {ongoingMatches.length > 0 ? (
            ongoingMatches.slice(0, 4).map(match => (
              <MatchCard key={match.id} match={match} />
            ))
          ) : (
            <div className="col-span-2 text-center py-12 text-gray-500 bg-white/5 rounded-3xl border border-dashed border-white/10">
              No live matches at the moment.
            </div>
          )}
        </div>
      </div>
    </div>
  );
};

// --- Match Card Component ---
const MatchCard = ({ match }) => {
  return (
    <GlassCard className="group overflow-hidden">
      <div className="relative p-4 flex gap-4 items-center">
        <div className="relative w-20 h-20 rounded-2xl overflow-hidden bg-white/5 flex-shrink-0">
          <img src={`https://api.dicebear.com/7.x/identicon/svg?seed=${match.title}`} alt="Game" className="w-full h-full object-cover" />
          <div className="absolute inset-0 bg-gradient-to-t from-black/80 to-transparent"></div>
          <div className="absolute bottom-1 w-full text-center text-[8px] font-black">{match.mode}</div>
        </div>
        
        <div className="flex-grow space-y-2">
          <div className="flex justify-between items-start">
            <h4 className="font-black text-md leading-tight group-hover:text-[#FF6B00] transition-colors">{match.title}</h4>
            <div className="bg-[#FF6B00]/20 text-[#FF6B00] text-[10px] px-2 py-0.5 rounded-full font-black uppercase">
              {match.status}
            </div>
          </div>
          
          <div className="flex gap-4 text-[10px] text-gray-400 font-bold uppercase">
            <div className="flex flex-col">
              <span>Prize</span>
              <span className="text-white text-sm">₹{match.prize}</span>
            </div>
            <div className="flex flex-col">
              <span>Entry</span>
              <span className="text-white text-sm">{match.entry === 0 ? 'FREE' : `₹${match.entry}`}</span>
            </div>
            <div className="flex flex-col">
              <span>Time</span>
              <span className="text-white text-sm">{match.time}</span>
            </div>
          </div>
        </div>
      </div>
      <div className="px-4 pb-4">
         <button className="w-full bg-white/10 hover:bg-[#FF6B00] hover:text-black transition-all py-3 rounded-xl text-xs font-black uppercase tracking-widest">
            JOIN MATCH
         </button>
      </div>
    </GlassCard>
  );
};

// --- View: Social Chat (Discord-like) ---
const SocialChat = ({ userData, activeChat, setActiveChat }) => {
  const [messages, setMessages] = useState([]);
  const [msgInput, setMsgInput] = useState('');
  const chatEndRef = useRef(null);

  useEffect(() => {
    const q = collection(db, 'artifacts', appId, 'public', 'data', `chats_${activeChat}`);
    const unsubscribe = onSnapshot(q, (snapshot) => {
      const mList = snapshot.docs.map(doc => doc.data()).sort((a, b) => a.timestamp - b.timestamp);
      setMessages(mList);
      setTimeout(() => chatEndRef.current?.scrollIntoView({ behavior: 'smooth' }), 100);
    });
    return () => unsubscribe();
  }, [activeChat]);

  const sendMessage = async () => {
    if (!msgInput.trim()) return;
    const msgData = {
      sender: userData.username,
      senderId: userData.uid,
      text: msgInput,
      timestamp: Date.now(),
      role: userData.role
    };
    setMsgInput('');
    await addDoc(collection(db, 'artifacts', appId, 'public', 'data', `chats_${activeChat}`), msgData);
  };

  return (
    <div className="flex h-[75vh] gap-4 animate-in fade-in zoom-in-95 duration-500">
      {/* Sidebar */}
      <div className="hidden md:flex flex-col w-64 gap-2">
        <GlassCard className="p-4 flex-grow space-y-6">
          <div className="space-y-2">
            <span className="text-[10px] font-black text-gray-500 uppercase tracking-widest">Servers</span>
            <div className="flex flex-col gap-1">
              <button className="flex items-center gap-3 p-3 bg-[#FF6B00] text-black rounded-xl font-bold">
                <Trophy size={18} /> Community
              </button>
            </div>
          </div>
          
          <div className="space-y-2">
            <span className="text-[10px] font-black text-gray-500 uppercase tracking-widest">Channels</span>
            <div className="flex flex-col gap-1">
              {['general', 'announcements', 'squad-talk', 'match-discussions'].map(ch => (
                <button 
                  key={ch}
                  onClick={() => setActiveChat(ch)}
                  className={`flex items-center gap-2 p-3 rounded-xl text-sm font-bold transition-all ${activeChat === ch ? 'bg-white/10 text-white' : 'text-gray-400 hover:text-white hover:bg-white/5'}`}
                >
                  <Hash size={16} /> {ch}
                </button>
              ))}
            </div>
          </div>
        </GlassCard>
      </div>

      {/* Chat Window */}
      <GlassCard className="flex-grow flex flex-col overflow-hidden relative">
        <div className="p-4 border-b border-white/5 flex items-center justify-between">
          <div className="flex items-center gap-2">
            <Hash size={20} className="text-[#FF6B00]" />
            <h3 className="font-black uppercase tracking-tighter text-lg">{activeChat}</h3>
          </div>
          <Users size={20} className="text-gray-500" />
        </div>

        <div className="flex-grow overflow-y-auto p-4 space-y-4 custom-scrollbar">
          {messages.map((m, i) => (
            <div key={i} className={`flex flex-col ${m.senderId === userData.uid ? 'items-end' : 'items-start'}`}>
              <div className="flex items-center gap-2 mb-1">
                {m.role === 'admin' && <Crown size={12} className="text-yellow-500" />}
                <span className="text-[10px] font-black text-gray-500 uppercase">{m.sender}</span>
              </div>
              <div className={`px-4 py-2 rounded-2xl max-w-xs text-sm ${m.senderId === userData.uid ? 'bg-[#FF6B00] text-black font-medium' : 'bg-white/10 text-white'}`}>
                {m.text}
              </div>
            </div>
          ))}
          <div ref={chatEndRef} />
        </div>

        <div className="p-4 bg-black/40 border-t border-white/5">
          <div className="relative">
            <input 
              value={msgInput}
              onChange={(e) => setMsgInput(e.target.value)}
              onKeyPress={(e) => e.key === 'Enter' && sendMessage()}
              placeholder={`Message #${activeChat}`} 
              className="w-full bg-white/5 border border-white/10 rounded-2xl py-4 pl-6 pr-14 text-sm focus:outline-none focus:border-[#FF6B00]/50"
            />
            <button 
              onClick={sendMessage}
              className="absolute right-3 top-1/2 -translate-y-1/2 p-2 bg-[#FF6B00] text-black rounded-xl hover:scale-110 transition-all"
            >
              <Send size={18} />
            </button>
          </div>
        </div>
      </GlassCard>
    </div>
  );
};

// --- View: Wallet ---
const WalletView = ({ userData }) => {
  return (
    <div className="max-w-2xl mx-auto space-y-8 animate-in fade-in slide-in-from-bottom-8 duration-500">
      <div className="text-center space-y-2">
        <h2 className="text-3xl font-black italic uppercase tracking-tighter">ELITE WALLET</h2>
        <p className="text-gray-500 text-sm">Manage your funds and withdraw winnings</p>
      </div>

      <GlassCard className="p-8 relative overflow-hidden">
        <div className="absolute top-0 right-0 w-32 h-32 bg-[#FF6B00]/10 rounded-full blur-3xl -mr-16 -mt-16"></div>
        <div className="flex justify-between items-center relative z-10">
          <div className="space-y-1">
            <span className="text-xs font-black text-gray-500 uppercase tracking-widest">Total Balance</span>
            <div className="text-5xl font-black text-[#FF6B00]">₹{userData?.balance || 0}</div>
          </div>
          <div className="p-4 bg-white/5 rounded-3xl">
            <CreditCard size={40} strokeWidth={1.5} className="text-gray-400" />
          </div>
        </div>
      </GlassCard>

      <div className="grid grid-cols-2 gap-4">
        <button className="flex items-center justify-center gap-3 p-6 bg-[#FF6B00] text-black rounded-3xl font-black uppercase tracking-widest hover:scale-105 active:scale-95 transition-all">
          <Plus size={24} strokeWidth={3} /> Deposit
        </button>
        <button className="flex items-center justify-center gap-3 p-6 bg-white/5 border border-white/10 text-white rounded-3xl font-black uppercase tracking-widest hover:bg-white/10 hover:scale-105 active:scale-95 transition-all">
          <Wallet size={24} strokeWidth={2} /> Withdraw
        </button>
      </div>

      <div className="space-y-4">
        <h3 className="text-sm font-black uppercase tracking-widest text-gray-500 flex items-center gap-2">
          <Zap size={14} fill="currentColor" /> Recent Transactions
        </h3>
        <GlassCard className="divide-y divide-white/5">
          <div className="p-4 flex justify-between items-center">
            <div className="flex gap-4 items-center">
              <div className="w-10 h-10 rounded-xl bg-green-500/20 flex items-center justify-center text-green-500">
                <Plus size={20} />
              </div>
              <div className="flex flex-col">
                <span className="font-bold text-sm">Winning Bonus</span>
                <span className="text-[10px] text-gray-500">March 12, 2024</span>
              </div>
            </div>
            <span className="font-black text-green-500">+₹500</span>
          </div>
          <div className="p-4 flex justify-between items-center">
            <div className="flex gap-4 items-center">
              <div className="w-10 h-10 rounded-xl bg-red-500/20 flex items-center justify-center text-red-500">
                <ChevronRight size={20} className="rotate-90" />
              </div>
              <div className="flex flex-col">
                <span className="font-bold text-sm">Entry Fee: Match #102</span>
                <span className="text-[10px] text-gray-500">March 10, 2024</span>
              </div>
            </div>
            <span className="font-black text-red-500">-₹50</span>
          </div>
        </GlassCard>
      </div>
    </div>
  );
};

// --- View: Admin Panel ---
const AdminPanel = ({ matches }) => {
  const [newMatch, setNewMatch] = useState({
    title: '',
    mode: 'Solo',
    prize: 0,
    entry: 0,
    time: '',
    status: 'open'
  });

  const createMatch = async () => {
    if (!newMatch.title) return;
    await addDoc(collection(db, 'artifacts', appId, 'public', 'data', 'matches'), {
      ...newMatch,
      slots: 48,
      joined: 0,
      createdAt: Date.now()
    });
    setNewMatch({ title: '', mode: 'Solo', prize: 0, entry: 0, time: '', status: 'open' });
  };

  return (
    <div className="grid md:grid-cols-2 gap-8 animate-in zoom-in-95 duration-500">
      <div className="space-y-6">
        <h2 className="text-2xl font-black italic uppercase text-[#FF6B00]">Create Tournament</h2>
        <GlassCard className="p-6 space-y-4">
          <div className="space-y-2">
            <label className="text-[10px] font-black uppercase text-gray-500">Match Title</label>
            <input 
              value={newMatch.title}
              onChange={e => setNewMatch({...newMatch, title: e.target.value})}
              className="w-full bg-white/5 border border-white/10 rounded-xl p-3 focus:outline-none focus:border-[#FF6B00]" 
              placeholder="e.g. Sunday Mega Rush" 
            />
          </div>
          <div className="grid grid-cols-2 gap-4">
            <div className="space-y-2">
              <label className="text-[10px] font-black uppercase text-gray-500">Game Mode</label>
              <select 
                value={newMatch.mode}
                onChange={e => setNewMatch({...newMatch, mode: e.target.value})}
                className="w-full bg-white/5 border border-white/10 rounded-xl p-3 text-white focus:outline-none"
              >
                <option>Solo</option>
                <option>Duo</option>
                <option>Squad</option>
                <option>Clash Squad</option>
              </select>
            </div>
            <div className="space-y-2">
              <label className="text-[10px] font-black uppercase text-gray-500">Match Time</label>
              <input 
                type="datetime-local" 
                onChange={e => setNewMatch({...newMatch, time: e.target.value})}
                className="w-full bg-white/5 border border-white/10 rounded-xl p-3 focus:outline-none" 
              />
            </div>
          </div>
          <div className="grid grid-cols-2 gap-4">
             <div className="space-y-2">
              <label className="text-[10px] font-black uppercase text-gray-500">Prize Pool (₹)</label>
              <input 
                type="number" 
                value={newMatch.prize}
                onChange={e => setNewMatch({...newMatch, prize: Number(e.target.value)})}
                className="w-full bg-white/5 border border-white/10 rounded-xl p-3 focus:outline-none" 
              />
            </div>
            <div className="space-y-2">
              <label className="text-[10px] font-black uppercase text-gray-500">Entry Fee (₹)</label>
              <input 
                type="number" 
                value={newMatch.entry}
                onChange={e => setNewMatch({...newMatch, entry: Number(e.target.value)})}
                className="w-full bg-white/5 border border-white/10 rounded-xl p-3 focus:outline-none" 
              />
            </div>
          </div>
          <button 
            onClick={createMatch}
            className="w-full py-4 bg-[#FF6B00] text-black font-black uppercase rounded-xl hover:scale-[1.02] transition-all"
          >
            Deploy Tournament
          </button>
        </GlassCard>
      </div>

      <div className="space-y-6">
        <h2 className="text-2xl font-black italic uppercase text-[#FF6B00]">Active Deployments</h2>
        <div className="space-y-3">
          {matches.map(m => (
            <GlassCard key={m.id} className="p-4 flex justify-between items-center">
              <div>
                <div className="font-bold">{m.title}</div>
                <div className="text-[10px] text-gray-500 font-bold uppercase">{m.mode} • ₹{m.prize} Prize</div>
              </div>
              <div className="flex gap-2">
                <button className="p-2 bg-white/5 rounded-lg text-blue-400 hover:bg-blue-400 hover:text-white transition-all"><Settings size={18} /></button>
                <button className="p-2 bg-white/5 rounded-lg text-red-400 hover:bg-red-400 hover:text-white transition-all"><LogOut size={18} className="rotate-90" /></button>
              </div>
            </GlassCard>
          ))}
        </div>
      </div>
    </div>
  );
};

// --- View: Staff Panel ---
const StaffPanel = ({ matches }) => {
  return (
    <div className="space-y-6 animate-in fade-in duration-500">
      <div className="flex justify-between items-center">
        <h2 className="text-2xl font-black italic uppercase text-[#FF6B00]">Staff Match Control</h2>
        <div className="flex items-center gap-2 text-xs font-bold text-gray-500">
          <ShieldAlert size={14} className="text-yellow-500" /> Authorized Staff Access
        </div>
      </div>

      <div className="grid lg:grid-cols-3 gap-6">
        <div className="lg:col-span-2 space-y-4">
          {matches.map(match => (
            <GlassCard key={match.id} className="p-6">
              <div className="flex justify-between items-start mb-6">
                <div className="space-y-1">
                  <h3 className="text-xl font-black uppercase tracking-tighter">{match.title}</h3>
                  <p className="text-xs text-gray-500 font-bold uppercase">{match.mode} | Slot Status: <span className="text-[#FF6B00]">48/48 (ROOM 1 FULL)</span></p>
                </div>
                <div className="bg-green-500/10 text-green-500 text-[10px] px-3 py-1 rounded-full font-black uppercase border border-green-500/20">
                  Live
                </div>
              </div>

              <div className="grid grid-cols-2 md:grid-cols-3 gap-4 mb-6">
                <div className="bg-white/5 p-3 rounded-xl border border-white/5 space-y-1">
                  <span className="text-[10px] text-gray-500 font-bold uppercase">Room ID</span>
                  <input className="w-full bg-transparent border-none text-white font-black text-sm p-0 focus:ring-0" defaultValue="7128381" />
                </div>
                <div className="bg-white/5 p-3 rounded-xl border border-white/5 space-y-1">
                  <span className="text-[10px] text-gray-500 font-bold uppercase">Password</span>
                  <input className="w-full bg-transparent border-none text-white font-black text-sm p-0 focus:ring-0" defaultValue="ELITE99" />
                </div>
                <button className="bg-[#FF6B00] text-black font-black uppercase text-[10px] rounded-xl hover:scale-105 transition-all">Update Room Info</button>
              </div>

              <div className="flex gap-4">
                 <button className="flex-1 py-3 bg-red-500 text-white text-xs font-black uppercase rounded-xl flex items-center justify-center gap-2 hover:bg-red-600 transition-all">
                    <ShieldAlert size={16} /> Cancel (Hacker Detected)
                 </button>
                 <button className="flex-1 py-3 bg-white/10 text-white text-xs font-black uppercase rounded-xl hover:bg-white/20 transition-all">
                    Spectate Room
                 </button>
              </div>
            </GlassCard>
          ))}
        </div>

        <div className="space-y-4">
          <h3 className="text-sm font-black uppercase tracking-widest text-gray-500">Player Watchlist</h3>
          <GlassCard className="p-4 space-y-4">
             {[
               { name: 'ShadowX', uid: '712838282', level: 67 },
               { name: 'DemonYT', uid: '827272611', level: 59 },
               { name: 'SkyHigh', uid: '112938221', level: 71 },
             ].map((p, i) => (
               <div key={i} className="flex justify-between items-center border-b border-white/5 pb-3 last:border-0 last:pb-0">
                 <div className="flex flex-col">
                   <span className="font-bold text-sm">{p.name}</span>
                   <span className="text-[10px] text-gray-500 uppercase">UID: {p.uid}</span>
                 </div>
                 <div className="bg-white/10 px-2 py-1 rounded text-[10px] font-black">LVL {p.level}</div>
               </div>
             ))}
             <button className="w-full text-xs font-black text-[#FF6B00] hover:underline pt-2">VIEW ALL PLAYERS</button>
          </GlassCard>
        </div>
      </div>
    </div>
  );
};

// --- View: Profile ---
const ProfileView = ({ userData, setUserData }) => {
  return (
    <div className="max-w-xl mx-auto space-y-8 animate-in fade-in slide-in-from-bottom-8 duration-500">
      <div className="flex flex-col items-center gap-4">
        <div className="w-32 h-32 rounded-3xl bg-gradient-to-tr from-[#FF6B00] to-orange-400 p-1 relative">
          <div className="w-full h-full bg-[#0A0A0A] rounded-[22px] flex items-center justify-center relative overflow-hidden">
             <UserIcon size={64} className="text-gray-700" />
             <div className="absolute bottom-0 w-full bg-[#FF6B00]/80 text-black text-[10px] font-black text-center py-1">RANK #12</div>
          </div>
        </div>
        <div className="text-center">
          <h2 className="text-2xl font-black italic uppercase">{userData?.username}</h2>
          <p className="text-[#FF6B00] font-black text-xs uppercase tracking-widest">{userData?.elitestarId}</p>
        </div>
      </div>

      <GlassCard className="divide-y divide-white/5 overflow-hidden">
        {[
          { label: 'Free Fire Name', value: userData?.ffName || 'Not Set', icon: Sword },
          { label: 'Free Fire UID', value: userData?.ffId || 'Not Set', icon: Hash },
          { label: 'Account Level', value: userData?.level || 1, icon: Zap },
          { label: 'Role', value: userData?.role?.toUpperCase(), icon: ShieldCheck },
        ].map((item, i) => (
          <div key={i} className="p-5 flex justify-between items-center group hover:bg-white/5 transition-all">
            <div className="flex items-center gap-4">
              <item.icon size={20} className="text-[#FF6B00]" />
              <div className="flex flex-col">
                <span className="text-[10px] font-black text-gray-500 uppercase">{item.label}</span>
                <span className="font-bold">{item.value}</span>
              </div>
            </div>
            <button className="text-xs font-black text-gray-500 hover:text-white uppercase transition-all">Edit</button>
          </div>
        ))}
      </GlassCard>

      <button className="w-full py-4 border border-red-500/20 text-red-500 font-black uppercase text-xs rounded-2xl hover:bg-red-500/10 transition-all flex items-center justify-center gap-2">
        <LogOut size={16} /> Sign Out Account
      </button>
    </div>
  );
};

// --- Elite Bot (AI Assistant) ---
const EliteBot = () => {
  const [open, setOpen] = useState(false);
  const [messages, setMessages] = useState([
    { role: 'bot', text: 'Namaste! Main ELITE BOT hoon. Main aapki kaise madad kar sakta hoon?' }
  ]);
  const [input, setInput] = useState('');

  const askBot = () => {
    if (!input) return;
    const userMsg = input.toLowerCase();
    let reply = "Maaf kijiye, mujhe is baare mein jaankari nahi hai. Aap Staff se sampark karein.";
    
    if (userMsg.includes('withdraw')) reply = "Aap Wallet section mein jaakar withdraw request daal sakte hain. Admin 24 hours mein verify karenge.";
    if (userMsg.includes('match')) reply = "Next match aaj sham 7:00 PM baje hai. Dashboad check karein!";
    if (userMsg.includes('squad')) reply = "Squad join karne ke liye profile section mein 'Join Squad' ka option use karein.";

    setMessages([...messages, { role: 'user', text: input }, { role: 'bot', text: reply }]);
    setInput('');
  };

  return (
    <div className="fixed bottom-24 right-4 z-[60]">
      {open && (
        <GlassCard className="absolute bottom-16 right-0 w-72 h-96 flex flex-col overflow-hidden animate-in slide-in-from-bottom-4 duration-300 !bg-black/90">
          <div className="p-4 bg-[#FF6B00] text-black flex items-center gap-2">
            <Bot size={20} fill="currentColor" />
            <span className="font-black text-xs uppercase">Elite Assistant</span>
          </div>
          <div className="flex-grow overflow-y-auto p-4 space-y-3 text-[11px]">
            {messages.map((m, i) => (
              <div key={i} className={`p-2 rounded-xl ${m.role === 'bot' ? 'bg-white/10 text-white self-start' : 'bg-[#FF6B00] text-black font-medium self-end ml-8'}`}>
                {m.text}
              </div>
            ))}
          </div>
          <div className="p-2 border-t border-white/10 flex gap-2">
            <input 
              value={input}
              onChange={e => setInput(e.target.value)}
              onKeyPress={e => e.key === 'Enter' && askBot()}
              className="flex-grow bg-white/5 border border-white/10 rounded-lg p-2 text-[10px] focus:outline-none" 
              placeholder="Aapka sawal?" 
            />
            <button onClick={askBot} className="bg-[#FF6B00] p-2 rounded-lg text-black"><Send size={14} /></button>
          </div>
        </GlassCard>
      )}
      <button 
        onClick={() => setOpen(!open)}
        className="w-14 h-14 bg-[#FF6B00] text-black rounded-full shadow-[0_0_20px_rgba(255,107,0,0.5)] flex items-center justify-center hover:scale-110 active:scale-90 transition-all"
      >
        <Bot size={28} />
      </button>
    </div>
  );
};

export default App;

