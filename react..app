<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ELITESTAR - Esports Platform</title>
    <!-- Tailwind CSS for Styling -->
    <script src="https://cdn.tailwindcss.com"></script>
    <!-- React & ReactDOM from CDN -->
    <script src="https://unpkg.com/react@18/umd/react.production.min.js"></script>
    <script src="https://unpkg.com/react-dom@18/umd/react-dom.production.min.js"></script>
    <!-- Babel for JSX -->
    <script src="https://unpkg.com/@babel/standalone/babel.min.js"></script>
    <!-- Lucide Icons -->
    <script src="https://unpkg.com/lucide@latest"></script>
    <!-- Firebase SDKs -->
    <script src="https://www.gstatic.com/firebasejs/11.0.2/firebase-app-compat.js"></script>
    <script src="https://www.gstatic.com/firebasejs/11.0.2/firebase-auth-compat.js"></script>
    <script src="https://www.gstatic.com/firebasejs/11.0.2/firebase-firestore-compat.js"></script>

    <style>
        @import url('https://fonts.googleapis.com/css2?family=Orbitron:wght@400;700;900&family=Inter:wght@300;400;700&display=swap');
        
        body {
            background-color: #0A0A0A;
            color: white;
            font-family: 'Inter', sans-serif;
            margin: 0;
            padding: 0;
            overflow-x: hidden;
        }

        .font-gaming { font-family: 'Orbitron', sans-serif; }
        
        .glass {
            background: rgba(255, 255, 255, 0.03);
            backdrop-filter: blur(10px);
            border: 1px solid rgba(255, 255, 255, 0.05);
        }

        .neon-border {
            border: 1px solid #FF6B00;
            box-shadow: 0 0 10px rgba(255, 107, 0, 0.3);
        }

        .neon-text {
            color: #FF6B00;
            text-shadow: 0 0 5px rgba(255, 107, 0, 0.5);
        }

        /* Mobile specific adjustments */
        .safe-bottom { padding-bottom: env(safe-area-inset-bottom); }
        
        ::-webkit-scrollbar { width: 0px; }
    </style>
</head>
<body>
    <div id="root"></div>

    <script type="text/babel">
        const { useState, useEffect, useRef } = React;

        // --- Firebase Config (Empty - User will fill) ---
        // Phone par setup karte waqt yahan apni keys dalein
        const firebaseConfig = {
            apiKey: "",
            authDomain: "",
            projectId: "",
            storageBucket: "",
            messagingSenderId: "",
            appId: ""
        };

        // Initialize Firebase
        if (!firebase.apps.length) {
            firebase.initializeApp(firebaseConfig);
        }
        const auth = firebase.auth();
        const db = firebase.firestore();
        const appId = "elitestar-mobile-v1";

        // --- Helper Components ---
        const Icon = ({ name, size = 20, className = "" }) => {
            const [iconSvg, setIconSvg] = useState('');
            useEffect(() => {
                if (window.lucide) {
                    const icon = window.lucide.icons[name];
                    if (icon) setIconSvg(icon.toSvg({ width: size, height: size, class: className }));
                }
            }, [name, size, className]);
            return <span dangerouslySetInnerHTML={{ __html: iconSvg }} />;
        };

        // --- Main App Component ---
        const App = () => {
            const [user, setUser] = useState(null);
            const [profile, setProfile] = useState(null);
            const [view, setView] = useState('home'); // home, play, chat, wallet, admin
            const [matches, setMatches] = useState([]);
            const [loading, setLoading] = useState(true);

            // Auth Logic
            useEffect(() => {
                const unsubscribe = auth.onAuthStateChanged(async (u) => {
                    if (u) {
                        setUser(u);
                        await syncProfile(u.uid);
                    } else {
                        // For demo/dev purpose auto-login anonymously
                        try { await auth.signInAnonymously(); } catch(e) { console.error(e); }
                    }
                });
                return () => unsubscribe();
            }, []);

            const syncProfile = async (uid) => {
                const docRef = db.collection('artifacts').doc(appId).collection('users').doc(uid).collection('profile').doc('data');
                const snap = await docRef.get();
                if (snap.exists) {
                    setProfile(snap.data());
                } else {
                    const newProfile = {
                        username: "Gamer_" + Math.floor(Math.random()*9999),
                        uid: uid,
                        elitestarId: "STAR-" + Math.floor(1000 + Math.random()*8000),
                        balance: 0,
                        role: 'user', // Change to 'admin' in Firestore manually
                        wins: 0,
                        played: 0
                    };
                    await docRef.set(newProfile);
                    setProfile(newProfile);
                }
                setLoading(false);
            };

            // Matches Sync
            useEffect(() => {
                if (!user) return;
                const unsub = db.collection('artifacts').doc(appId).collection('public').doc('data').collection('matches')
                    .onSnapshot(snap => {
                        const m = snap.docs.map(d => ({ id: d.id, ...d.data() }));
                        setMatches(m);
                    });
                return () => unsub();
            }, [user]);

            if (loading && user) {
                return (
                    <div className="h-screen flex items-center justify-center bg-black">
                        <div className="text-[#FF6B00] font-black animate-pulse">ELITESTAR LOADING...</div>
                    </div>
                );
            }

            return (
                <div className="max-w-md mx-auto min-h-screen relative pb-24">
                    {/* Header */}
                    <header className="p-4 flex justify-between items-center sticky top-0 bg-black/80 backdrop-blur-md z-50">
                        <div className="flex items-center gap-2">
                            <div className="bg-[#FF6B00] p-1.5 rounded-lg">
                                <Icon name="Trophy" size={18} className="text-black" />
                            </div>
                            <h1 className="font-gaming font-black text-xl italic tracking-tighter">
                                ELITE<span className="text-[#FF6B00]">STAR</span>
                            </h1>
                        </div>
                        <div className="flex items-center gap-3">
                            <button className="p-2 glass rounded-full text-gray-400">
                                <Icon name="Bell" size={18} />
                            </button>
                            <div className="w-9 h-9 rounded-full bg-gradient-to-tr from-[#FF6B00] to-orange-400 p-[1px]">
                                <div className="w-full h-full bg-black rounded-full flex items-center justify-center text-[10px] font-black">
                                    {profile?.username?.[0]?.toUpperCase()}
                                </div>
                            </div>
                        </div>
                    </header>

                    {/* Main Content View */}
                    <div className="px-4 py-2">
                        {view === 'home' && <HomeView profile={profile} matches={matches} />}
                        {view === 'play' && <PlayView matches={matches} />}
                        {view === 'chat' && <ChatView profile={profile} />}
                        {view === 'wallet' && <WalletView profile={profile} />}
                        {view === 'admin' && <AdminView matches={matches} appId={appId} db={db} />}
                    </div>

                    {/* Bottom Nav */}
                    <nav className="fixed bottom-0 left-0 right-0 max-w-md mx-auto p-4 safe-bottom">
                        <div className="glass rounded-3xl p-2 flex justify-around items-center border-white/10 shadow-2xl">
                            <NavBtn active={view === 'home'} icon="Layout" label="Home" onClick={() => setView('home')} />
                            <NavBtn active={view === 'play'} icon="Gamepad2" label="Play" onClick={() => setView('play')} />
                            <NavBtn active={view === 'chat'} icon="MessageSquare" label="Chat" onClick={() => setView('chat')} />
                            <NavBtn active={view === 'wallet'} icon="Wallet" label="Wallet" onClick={() => setView('wallet')} />
                            {profile?.role === 'admin' && (
                                <NavBtn active={view === 'admin'} icon="ShieldCheck" label="Admin" onClick={() => setView('admin')} />
                            )}
                        </div>
                    </nav>
                </div>
            );
        };

        const NavBtn = ({ active, icon, label, onClick }) => (
            <button onClick={onClick} className={`flex flex-col items-center gap-1 px-4 py-1 transition-all ${active ? 'text-[#FF6B00]' : 'text-gray-500'}`}>
                <Icon name={icon} size={22} className={active ? 'drop-shadow-[0_0_5px_rgba(255,107,0,0.5)]' : ''} />
                <span className="text-[9px] font-bold uppercase tracking-widest">{label}</span>
            </button>
        );

        // --- View: Home ---
        const HomeView = ({ profile, matches }) => (
            <div className="space-y-6">
                <div className="glass p-5 rounded-3xl relative overflow-hidden">
                    <div className="absolute -right-4 -top-4 w-24 h-24 bg-[#FF6B00]/10 rounded-full blur-2xl"></div>
                    <p className="text-[10px] font-black text-gray-500 uppercase tracking-widest mb-1">Welcome Commander</p>
                    <h2 className="text-2xl font-black italic">{profile?.username?.toUpperCase()}</h2>
                    <div className="flex gap-4 mt-4">
                        <div className="flex flex-col">
                            <span className="text-[9px] text-gray-500 font-bold">UID</span>
                            <span className="text-xs font-black text-[#FF6B00]">{profile?.elitestarId}</span>
                        </div>
                        <div className="flex flex-col border-l border-white/10 pl-4">
                            <span className="text-[9px] text-gray-500 font-bold">WINS</span>
                            <span className="text-xs font-black">{profile?.wins}</span>
                        </div>
                    </div>
                </div>

                <div className="relative h-40 rounded-3xl overflow-hidden glass border-[#FF6B00]/30 border">
                    <img src="https://images.unsplash.com/photo-1542751371-adc38448a05e?q=80&w=600" className="w-full h-full object-cover opacity-60" />
                    <div className="absolute inset-0 p-6 flex flex-col justify-end bg-gradient-to-t from-black to-transparent">
                        <span className="text-[#FF6B00] text-[10px] font-black">SEASON 12 IS LIVE</span>
                        <h3 className="text-xl font-black italic uppercase">Mega Prize Pool Match</h3>
                    </div>
                </div>

                <div className="space-y-4">
                    <div className="flex justify-between items-center">
                        <h4 className="font-gaming text-sm font-black italic border-l-2 border-[#FF6B00] pl-3 uppercase">Featured Matches</h4>
                        <span className="text-[10px] font-bold text-[#FF6B00]">SEE ALL</span>
                    </div>
                    {matches.length === 0 ? (
                        <div className="text-center py-8 glass rounded-2xl text-gray-500 text-xs font-bold">No active matches found.</div>
                    ) : (
                        matches.slice(0, 3).map(m => <MatchCard key={m.id} match={m} />)
                    )}
                </div>
            </div>
        );

        const MatchCard = ({ match }) => (
            <div className="glass p-4 rounded-2xl flex gap-4 items-center border-l-4 border-l-[#FF6B00]">
                <div className="w-16 h-16 bg-white/5 rounded-xl flex items-center justify-center font-black text-gray-700">FF</div>
                <div className="flex-grow">
                    <h5 className="font-bold text-sm uppercase">{match.title}</h5>
                    <div className="flex gap-3 mt-1 text-[10px] font-bold text-gray-400">
                        <span>{match.mode}</span>
                        <span className="text-[#FF6B00]">₹{match.prize} Prize</span>
                    </div>
                </div>
                <button className="bg-[#FF6B00] text-black px-4 py-2 rounded-lg text-[10px] font-black uppercase">JOIN</button>
            </div>
        );

        // --- View: Play (More detail) ---
        const PlayView = ({ matches }) => (
            <div className="space-y-4">
                <h2 className="font-gaming text-lg font-black italic uppercase">All Tournaments</h2>
                {matches.map(m => <MatchCard key={m.id} match={m} />)}
            </div>
        );

        // --- View: Chat ---
        const ChatView = ({ profile }) => {
            const [msgs, setMsgs] = useState([]);
            const [input, setInput] = useState('');
            
            useEffect(() => {
                const unsub = db.collection('artifacts').doc(appId).collection('public').doc('data').collection('chats_general')
                    .orderBy('timestamp', 'desc').limit(20)
                    .onSnapshot(snap => {
                        setMsgs(snap.docs.map(d => d.data()).reverse());
                    });
                return () => unsub();
            }, []);

            const send = async () => {
                if (!input.trim()) return;
                await db.collection('artifacts').doc(appId).collection('public').doc('data').collection('chats_general').add({
                    sender: profile.username,
                    text: input,
                    timestamp: Date.now(),
                    uid: profile.uid
                });
                setInput('');
            };

            return (
                <div className="flex flex-col h-[70vh] glass rounded-3xl overflow-hidden">
                    <div className="p-4 border-b border-white/5 flex items-center gap-2">
                        <Icon name="Hash" size={18} className="text-[#FF6B00]" />
                        <span className="font-black text-sm uppercase tracking-tighter">Global Chat</span>
                    </div>
                    <div className="flex-grow overflow-y-auto p-4 space-y-3">
                        {msgs.map((m, i) => (
                            <div key={i} className={`flex flex-col ${m.uid === profile.uid ? 'items-end' : 'items-start'}`}>
                                <span className="text-[8px] text-gray-500 font-bold uppercase mb-1">{m.sender}</span>
                                <div className={`px-4 py-2 rounded-2xl text-xs ${m.uid === profile.uid ? 'bg-[#FF6B00] text-black font-bold' : 'bg-white/10 text-white'}`}>
                                    {m.text}
                                </div>
                            </div>
                        ))}
                    </div>
                    <div className="p-3 bg-black/50 flex gap-2">
                        <input 
                            value={input}
                            onChange={e => setInput(e.target.value)}
                            onKeyPress={e => e.key === 'Enter' && send()}
                            className="flex-grow bg-white/5 border border-white/10 rounded-xl px-4 text-xs focus:outline-none focus:border-[#FF6B00]" 
                            placeholder="Type message..." 
                        />
                        <button onClick={send} className="bg-[#FF6B00] p-3 rounded-xl text-black">
                            <Icon name="Send" size={16} />
                        </button>
                    </div>
                </div>
            );
        };

        // --- View: Wallet ---
        const WalletView = ({ profile }) => (
            <div className="space-y-6">
                <div className="text-center py-4">
                    <h2 className="font-gaming text-xl font-black italic uppercase">Wallet Balance</h2>
                </div>
                <div className="glass p-10 rounded-[40px] text-center border-[#FF6B00]/20 border relative overflow-hidden">
                    <div className="absolute top-0 left-0 w-full h-1 bg-gradient-to-r from-transparent via-[#FF6B00] to-transparent"></div>
                    <span className="text-[10px] font-black text-gray-500 uppercase tracking-[4px]">Available Funds</span>
                    <div className="text-6xl font-black mt-2 text-[#FF6B00]">₹{profile?.balance}</div>
                </div>
                <div className="grid grid-cols-2 gap-4">
                    <button className="bg-[#FF6B00] text-black font-black p-5 rounded-3xl uppercase text-xs hover:scale-105 transition-all">Deposit</button>
                    <button className="glass font-black p-5 rounded-3xl uppercase text-xs border-white/10 hover:bg-white/5 transition-all">Withdraw</button>
                </div>
                <div className="space-y-3">
                    <span className="text-[10px] font-black text-gray-500 uppercase tracking-widest">History</span>
                    <div className="glass rounded-2xl p-4 text-xs text-gray-500 italic text-center">No transactions yet.</div>
                </div>
            </div>
        );

        // --- View: Admin ---
        const AdminView = ({ matches, appId, db }) => {
            const [title, setTitle] = useState('');
            const [prize, setPrize] = useState('');
            
            const createMatch = async () => {
                if (!title || !prize) return;
                await db.collection('artifacts').doc(appId).collection('public').doc('data').collection('matches').add({
                    title,
                    prize: Number(prize),
                    mode: 'Solo',
                    status: 'open',
                    createdAt: Date.now()
                });
                setTitle(''); setPrize('');
                alert("Match Created!");
            };

            return (
                <div className="space-y-6">
                    <h2 className="font-gaming text-lg font-black text-[#FF6B00]">Admin Panel</h2>
                    <div className="glass p-5 rounded-2xl space-y-4">
                        <div className="space-y-2">
                            <label className="text-[10px] font-black text-gray-500 uppercase">Match Title</label>
                            <input value={title} onChange={e => setTitle(e.target.value)} className="w-full bg-white/5 border border-white/10 rounded-xl p-3 text-sm focus:outline-none focus:border-[#FF6B00]" placeholder="Enter Match Name" />
                        </div>
                        <div className="space-y-2">
                            <label className="text-[10px] font-black text-gray-500 uppercase">Prize Amount</label>
                            <input type="number" value={prize} onChange={e => setPrize(e.target.value)} className="w-full bg-white/5 border border-white/10 rounded-xl p-3 text-sm focus:outline-none focus:border-[#FF6B00]" placeholder="1000" />
                        </div>
                        <button onClick={createMatch} className="w-full bg-[#FF6B00] text-black font-black p-4 rounded-xl uppercase text-sm">Create Tournament</button>
                    </div>
                </div>
            );
        };

        const root = ReactDOM.createRoot(document.getElementById('root'));
        root.render(<App />);
    </script>
</body>
</html>

