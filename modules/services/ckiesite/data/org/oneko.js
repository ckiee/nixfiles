/* Copyright © 2022 adryd

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/
(()=>{
    const beds =
          [...document.querySelectorAll("nekobed")]
          .map(el=>({el,pos:()=>recurseOffsetPos(el)}));
    nekoEl = document.createElement("div");
    let nekoPosX = beds[0].pos()[0], nekoPosY = beds[0].pos()[1]
    frameCount = 0,    idleTime = 0,
    idleAnimation = null, idleAnimationFrame = 0;
    nekoSpeed = 7, idleUnix = Date.now(), startUnix = Date.now(),
    nekoTargetFn = beds[0].pos;
    const spriteSets =
{idle: [[-3, -3]], alert: [[-7, -3]], scratch: [[-5, 0], [-6, 0], [-7, 0],],
 tired: [[-3, -2]], sleeping: [[-2, 0], [-2, -1],], N: [[-1, -2], [-1, -3],],
 NE: [[0, -2], [0, -3],], E: [[-3, 0], [-3, -1],], SE: [[-5, -1], [-5, -2],], S: [[-6, -3], [-7, -2],], SW: [[-5, -3], [-6, -1],], W: [[-4, -2], [-4, -3],], NW: [[-1, 0], [-1, -1],],};

    function recurseOffsetPos(el) {
        let x=0,y=0;
        let cur={offsetParent:el};
        while (cur=cur.offsetParent) {
            x+=cur.offsetLeft;
            y+=cur.offsetTop;
        }
        ret=[x+32,y+32+(el.offsetHeight/2)];
        // console.log(el, "at", ret);
        return ret;
    }


    function create() {
        nekoEl.id = "oneko";
        (()=>{
            s=nekoEl.style;
            s.width = s.height = "32px";
            s.position = "absolute";
            s.backgroundImage = `url("./oneko.gif")`;
            s.imageRendering = "pixelated";
            s.left = `${nekoPosX - 16}px`;
            s.top = `${nekoPosY - 16}px`;
        })();

        document.body.appendChild(nekoEl);

        let retargetTimeout;

        (reconsider = fpos=>{
            const dist    = to => Math.sqrt(fpos.map((x,i)=>(~~(x-to[i]))**2).reduce((x,y)=>x+y));
            // closest bed above the cursor
            const targets = beds.sort((x,y)=>dist(x.pos())-dist(y.pos())).filter(x=>x.pos()[1]<=fpos[1]);
            const target  = targets[0];
            if (target) {
                let oldFn = nekoTargetFn;
                if (oldFn == nekoTargetFn) {
                    // this is actually a new target, but we may
                    // have just moved so we're confused
                    const sinceLastMove = Date.now() - idleUnix;
                    clearTimeout(retargetTimeout);
                    retargetTimeout = setTimeout(
                        () => { nekoTargetFn = target.pos },
                        // cats slow :P, 50ms wavelength = 20hz
                        sinceLastMove > 800 ? 50 : 400 // really lazy too sometimes
                    );
                } else {
                    idleUnix = Date.now();
                }
            }
        })(beds[0].pos());
        document.onmousemove = e => reconsider([e.layerX,e.layerY]);

        window.onekoInterval = setInterval(frame, 100);
    }

    function setSprite(name, frame) {
        const sprite = spriteSets[name][frame % spriteSets[name].length];
        nekoEl.style.backgroundPosition = `${sprite[0] * 32}px ${
            sprite[1] * 32
        }px`;
    }

    function resetIdleAnimation() {
        idleAnimation = null;
        idleAnimationFrame = 0;
    }

    function idle() {
        idleTime += 1;

        // every ~ 20 seconds
        if (
            idleTime > 10 &&
            Math.floor(Math.random() * 200) == 0 &&
            idleAnimation == null
        ) {
            idleAnimation = ["sleeping", "scratch"][
                Math.floor(Math.random() * 2)
            ];
        }

        switch (idleAnimation) {
            case "sleeping":
                if (idleAnimationFrame < 8) {
                    setSprite("tired", 0);
                    break;
                }
                setSprite("sleeping", Math.floor(idleAnimationFrame / 4));
                if (idleAnimationFrame > 192) {
                    resetIdleAnimation();
                }
                break;
            case "scratch":
                setSprite("scratch", idleAnimationFrame);
                if (idleAnimationFrame > 9) {
                    resetIdleAnimation();
                }
                break;
            default:
                setSprite("idle", 0);
                return;
        }
        idleAnimationFrame += 1;
    }

    function frame() {
        frameCount += 1;
        const [tx, ty] = nekoTargetFn();
        const diffX = nekoPosX - tx;
        const diffY = nekoPosY - ty;
        const distance = Math.sqrt(diffX ** 2 + diffY ** 2);
        nekoSpeed =10;//Math.max((Date.now() - idleUnix) / 5000 * 20, Math.max((Date.now() - startUnix) / 60000, 0.5));

        const pxInaccuracy = 2;
        if (distance < pxInaccuracy) {
            idle();
            return;
        }
        const unquantizeSpeed = distance / 1.2;
        const localNekoSpeed = distance > pxInaccuracy && distance < nekoSpeed ? unquantizeSpeed : nekoSpeed;
        console.log(localNekoSpeed)

        idleAnimation = null;
        idleAnimationFrame = 0;

        if (idleTime > 1) {
            setSprite("alert", 0);
            // count down after being alerted before moving
            idleTime = Math.min(idleTime, 7);
            idleTime -= 1;
            return;
        }

        direction = diffY / distance > 0.5 ? "N" : "";
        direction += diffY / distance < -0.5 ? "S" : "";
        direction += diffX / distance > 0.5 ? "W" : "";
        direction += diffX / distance < -0.5 ? "E" : "";
        setSprite(direction, frameCount);

        nekoPosX -= (diffX / distance) * localNekoSpeed;
        nekoPosY -= (diffY / distance) * localNekoSpeed;

        nekoEl.style.left = `${nekoPosX - 16}px`;
        nekoEl.style.top = `${nekoPosY - 16}px`;
    }

    create();
})();
