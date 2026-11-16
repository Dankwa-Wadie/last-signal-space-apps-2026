// The website's Tranquility height (getSurfaceHeight, test.html) sampled on the Roblox site,
// at 0.4 m per stud (the mapping the website uses for the game's layout). Output: studs.
import fs from 'fs';
function createRng(seed){let s=seed>>>0;return()=>{s=(s+0x6d2b79f5)|0;let t=Math.imul(s^(s>>>15),1|s);t=(t+Math.imul(t^(t>>>7),61|t))^t;return((t^(t>>>14))>>>0)/4294967296;};}
function hash2(x,y){const h=Math.sin(x*127.1+y*311.7)*43758.5453123;return h-Math.floor(h);}
function noise2D(x,y){const ix=Math.floor(x),iy=Math.floor(y),fx=x-ix,fy=y-iy,ux=fx*fx*(3-2*fx),uy=fy*fy*(3-2*fy);const a=hash2(ix,iy),b=hash2(ix+1,iy),c=hash2(ix,iy+1),d=hash2(ix+1,iy+1);return a+(b-a)*ux+(c-a)*uy+(a-b-c+d)*ux*uy;}
function fbm2D(x,y,o=5,l=2.07,g=0.5){let s=0,a=.5,f=1,n=0;for(let i=0;i<o;i++){s+=a*noise2D(x*f,y*f);n+=a;a*=g;f*=l;}return s/n;}
const smooth=(x,a,b)=>{const t=Math.min(1,Math.max(0,(x-a)/(b-a)));return t*t*(3-2*t);};
const lerp=(a,b,t)=>a+(b-a)*t;
// craters exactly as generateSiteCraters(Tranquility)
const rng=createRng(Math.round((0.67416+90)*1000+(23.47314+180)*137));const craters=[];
for(let i=0;i<65;i++){const ang=rng()*Math.PI*2,dist=12+Math.pow(rng(),.78)*185,cx=Math.cos(ang)*dist,cz=Math.sin(ang)*dist,r=1.8+Math.pow(rng(),2.1)*18,depth=r*(.16+rng()*.08);craters.push({cx,cz,r,depth});}
function H(x,z){ // metres, website coordinates
  const dist=Math.hypot(x,z);
  const macro=fbm2D(x*.011+4.3,z*.011-9.1,5),med=fbm2D(x*.045-2.1,z*.045+7.4,4),fine=fbm2D(x*.22+1.5,z*.22-3.8,3),micro=noise2D(x*1.1,z*1.1);
  let h=(macro-.5)*3.4+(med-.5)*.85+(fine-.5)*.22+(micro-.5)*.05;
  const ridge=Math.exp(-Math.pow((z+85)*.025,2))*4.5; h=h*.52+ridge;
  for(const c of craters){const dx=x-c.cx,dz=z-c.cz,d2=dx*dx+dz*dz,m=c.r*1.55;if(d2<m*m){const nr=Math.sqrt(d2)/c.r;if(nr<1)h-=c.depth*(1-nr*nr);else h+=Math.exp(-Math.pow((nr-1)*4.5,2))*(c.depth*.26);}}
  if(dist<7.5)h=lerp(0,h,smooth(dist,2.5,7.5));
  const ex=Math.max(0,Math.abs(x)-10),ez=Math.max(0,Math.abs(z-66)-13),sd=Math.hypot(ex,ez);if(sd<6)h=lerp(0,h,smooth(sd,0,6));
  return h;
}
const foot=fs.readFileSync(process.argv[2]+'/foot.txt','utf8').trim().split(';').map(s=>s.split(',').map(Number));
const STEP=8,MIN=-480,N=121;   // studs: -480..480
const vals=[];let lo=1e9,hi=-1e9;
for(let j=0;j<N;j++){const z=MIN+j*STEP;for(let i=0;i<N;i++){const x=MIN+i*STEP;
  let h=H(x*.4,z*.4)/.4;   // studs
  // level ground under every object of the site, blending back over 10 studs
  let k=1;for(const [fx,fz,fr] of foot){const d=Math.hypot(x-fx,z-fz)-(fr+3);if(d<12)k=Math.min(k,smooth(d,0,12));}
  h*=k;
  // and fade out towards the edge of the patch, so it meets the level ground around it
  const edge=Math.max(Math.abs(x),Math.abs(z));h*=1-smooth(edge,400,476);
  vals.push(h);lo=Math.min(lo,h);hi=Math.max(hi,h);}}
// encode: 0.05-stud steps, offset, 2 chars each from a 64-char alphabet (4096 levels)
const A='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
const OFF=-100;let s='';for(const v of vals){let q=Math.round((v-OFF)/.05);q=Math.max(0,Math.min(4095,q));s+=A[q>>6]+A[q&63];}
fs.writeFileSync(process.argv[2]+'/relief.txt',s);
console.log(`range ${lo.toFixed(2)}..${hi.toFixed(2)} studs, ${vals.length} samples, ${s.length} chars`);
