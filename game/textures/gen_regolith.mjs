// Renders the website's synthesizeRegolithMaps (test.html) to PNG, unchanged maths.
import zlib from 'zlib'; import fs from 'fs';
function createRng(seed){let s=seed>>>0;return()=>{s=(s+0x6d2b79f5)|0;let t=Math.imul(s^(s>>>15),1|s);t=(t+Math.imul(t^(t>>>7),61|t))^t;return((t^(t>>>14))>>>0)/4294967296;};}
function hash2(x,y){const h=Math.sin(x*127.1+y*311.7)*43758.5453123;return h-Math.floor(h);}
function noise2D(x,y){const ix=Math.floor(x),iy=Math.floor(y),fx=x-ix,fy=y-iy,ux=fx*fx*(3-2*fx),uy=fy*fy*(3-2*fy);const a=hash2(ix,iy),b=hash2(ix+1,iy),c=hash2(ix,iy+1),d=hash2(ix+1,iy+1);return a+(b-a)*ux+(c-a)*uy+(a-b-c+d)*ux*uy;}
function fbm2D(x,y,o=5,l=2.07,g=0.5){let s=0,a=.5,f=1,n=0;for(let i=0;i<o;i++){s+=a*noise2D(x*f,y*f);n+=a;a*=g;f*=l;}return s/n;}
const clamp=(v,a,b)=>Math.min(b,Math.max(a,v));
const size=1024;
const alb=Buffer.alloc(size*size*4),nor=Buffer.alloc(size*size*4),rou=Buffer.alloc(size*size*4);
const heights=new Float32Array(size*size);
const rng=createRng(88421);const pits=[];for(let i=0;i<220;i++)pits.push({x:rng()*size,y:rng()*size,r:2.5+Math.pow(rng(),2.5)*14,depth:.25+rng()*.45});
for(let y=0;y<size;y++){const ny=y/size*16;for(let x=0;x<size;x++){const nx=x/size*16;
 const n1=fbm2D(nx,ny,4),n2=noise2D(nx*5+3.1,ny*5-1.7),grain=hash2(x*1.9,y*2.3),sparkle=grain>.992?.24:0;
 let h=n1*.55+n2*.3+grain*.15;
 for(const p of pits){let dx=Math.abs(x-p.x),dy=Math.abs(y-p.y);if(dx>size*.5)dx=size-dx;if(dy>size*.5)dy=size-dy;const d2=dx*dx+dy*dy,m=p.r*1.35;if(d2<m*m){const nr=Math.sqrt(d2)/p.r;if(nr<1)h-=p.depth*(1-nr*nr);else h+=p.depth*.22*Math.exp(-Math.pow((nr-1)*4.5,2));}}
 heights[y*size+x]=h;const lum=clamp(.68+(h-.5)*.28+sparkle,.35,1),i=(y*size+x)*4;
 alb[i]=Math.round(lum*255);alb[i+1]=Math.round(lum*252);alb[i+2]=Math.round(lum*246);alb[i+3]=255;
 const rb=Math.round(clamp(.92-sparkle*1.5+(.5-h)*.08,.65,.99)*255);rou[i]=rou[i+1]=rou[i+2]=rb;rou[i+3]=255;}}
for(let y=0;y<size;y++){const ym=(y-1+size)%size,yp=(y+1)%size;for(let x=0;x<size;x++){const xm=(x-1+size)%size,xp=(x+1)%size;
 const dx=(heights[y*size+xm]-heights[y*size+xp])*2.6,dy=(heights[ym*size+x]-heights[yp*size+x])*2.6,inv=1/Math.hypot(dx,dy,1),i=(y*size+x)*4;
 nor[i]=Math.round((dx*inv*.5+.5)*255);nor[i+1]=Math.round((dy*inv*.5+.5)*255);nor[i+2]=Math.round((inv*.5+.5)*255);nor[i+3]=255;}}
function png(buf,file){const raw=Buffer.alloc((size*4+1)*size);for(let y=0;y<size;y++){raw[y*(size*4+1)]=0;buf.copy(raw,y*(size*4+1)+1,y*size*4,(y+1)*size*4);}
 const crcT=new Int32Array(256).map((_,n)=>{let c=n;for(let k=0;k<8;k++)c=c&1?0xedb88320^(c>>>1):c>>>1;return c;});
 const crc=b=>{let c=-1;for(const v of b)c=crcT[(c^v)&255]^(c>>>8);return (c^-1)>>>0;};
 const chunk=(t,d)=>{const l=Buffer.alloc(4);l.writeUInt32BE(d.length);const td=Buffer.concat([Buffer.from(t),d]);const c=Buffer.alloc(4);c.writeUInt32BE(crc(td));return Buffer.concat([l,td,c]);};
 const ih=Buffer.alloc(13);ih.writeUInt32BE(size,0);ih.writeUInt32BE(size,4);ih[8]=8;ih[9]=6;
 fs.writeFileSync(file,Buffer.concat([Buffer.from([137,80,78,71,13,10,26,10]),chunk('IHDR',ih),chunk('IDAT',zlib.deflateSync(raw,{level:9})),chunk('IEND',Buffer.alloc(0))]));}
const out=process.argv[2];
png(alb,out+'/regolith_color.png');png(nor,out+'/regolith_normal.png');png(rou,out+'/regolith_roughness.png');console.log('done');
