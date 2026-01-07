/* ==========================================================================
   CONFIGURATIONS & VARIABLES GLOBALES
   ========================================================================== */

const charactersList = [
    'mario', 'luigi', 'peach', 'toad',
    'yoshi', 'bowser', 'dk', 'koopa'
];

const greenShellConfig = {
    folder: 'green-shell',
    baseName: 'green-shell',
    totalFrames: 3,
    currentFrame: 1,
    speed: 100,
    elementId: 'green-shell-img'
};

let kartsData = [];
let lastFrameTime = 0;
let nextAvailableRespawnTime = 0;

/* ==========================================================================
   UTILITAIRES
   ========================================================================== */

function getCharacterPath(charName) {
    return `static/img/${charName}/${charName}-static.png`;
}

function shuffleArray(array) {
    for (let i = array.length - 1; i > 0; i--) {
        const j = Math.floor(Math.random() * (i + 1));
        [array[i], array[j]] = [array[j], array[i]];
    }
    return array;
}

function randomRange(min, max) {
    return Math.random() * (max - min) + min;
}

function calculateSpeedPPS(screenWidth) {
    const isMobile = window.innerWidth < 769;
    const baseDuration = isMobile ? 4 : 8; 
    
    // Variation +/- 7%
    const variation = randomRange(0.80, 1.20);
    const distance = screenWidth + 150;
    
    return (distance / baseDuration) * variation;
}

/* ==========================================================================
   INITIALISATION ET LOGIQUE DES KARTS
   ========================================================================== */

function initCharacters() {
    const container = document.getElementById('karts-container');
    if (!container) return;

    container.innerHTML = ''; 
    kartsData = [];

    const shuffledChars = shuffleArray([...charactersList]);

    shuffledChars.forEach((charName, index) => {
        const wrapper = document.createElement('div');
        wrapper.classList.add('kart-container-moving');
        
        const verticalPos = 2 + (index * 3); 
        wrapper.style.bottom = `${verticalPos}%`;
        
        // Z-Index : Plus bas = Plus proche (Index inversé)
        wrapper.style.zIndex = 350 - index; 
        
        const startX = -150;
        wrapper.style.transform = `translateX(${startX}px)`;

        const img = document.createElement('img');
        img.src = getCharacterPath(charName);
        img.alt = charName;
        img.classList.add('kart-static-png');
        
        wrapper.appendChild(img);
        container.appendChild(wrapper);

        kartsData.push({
            element: wrapper,
            x: startX,
            speedPPS: 0, 
            state: 'waiting_initial',
            charName: charName
        });
    });

    spawnNextKart(0);
}

function spawnNextKart(index) {
    if (index >= kartsData.length) return;

    const kart = kartsData[index];
    startKartRun(kart);

    const delay = randomRange(500, 2000);
    setTimeout(() => {
        spawnNextKart(index + 1);
    }, delay);
}

function startKartRun(kart) {
    const container = document.getElementById('karts-container');
    if (!container) return;
    
    const screenWidth = container.offsetWidth;

    // Calcul de la NOUVELLE vitesse cible
    const newTargetSpeed = calculateSpeedPPS(screenWidth);

    // --- MISE A JOUR : LISSAGE DE LA VITESSE ---
    if (kart.speedPPS > 0) {
        // Ce n'est pas le premier tour, on fait la moyenne 
        // entre l'ancienne vitesse et la nouvelle pour éviter les changements brusques.
        kart.speedPPS = (kart.speedPPS + newTargetSpeed) / 2;
    } else {
        // Premier tour (vitesse initiale à 0), on prend la valeur directe
        kart.speedPPS = newTargetSpeed;
    }

    // Reset position à gauche
    kart.x = -150;
    kart.state = 'running';
}

/* ==========================================================================
   GESTION INTELLIGENTE DU RESPAWN
   ========================================================================== */

function scheduleRespawn(kart) {
    const now = Date.now();
    const naturalDelay = randomRange(7500, 9000);
    let targetTime = now + naturalDelay;

    if (targetTime < nextAvailableRespawnTime) {
        targetTime = nextAvailableRespawnTime;
    }

    nextAvailableRespawnTime = targetTime + 800; // Anti-clumping buffer

    const actualDelay = targetTime - now;

    setTimeout(() => {
        startKartRun(kart);
    }, actualDelay);
}

/* ==========================================================================
   BOUCLE D'ANIMATION
   ========================================================================== */

function animateKarts(timestamp) {
    if (!lastFrameTime) lastFrameTime = timestamp;
    const deltaTime = (timestamp - lastFrameTime) / 1000;
    lastFrameTime = timestamp;

    const container = document.getElementById('karts-container');
    
    if (container) {
        const screenWidth = container.offsetWidth;
        const limitX = screenWidth + 150;

        kartsData.forEach(kart => {
            if (kart.state === 'running') {
                const moveAmount = kart.speedPPS * deltaTime;
                kart.x += moveAmount;
                kart.element.style.transform = `translateX(${kart.x}px)`;

                if (kart.x > limitX) {
                    kart.state = 'waiting_respawn';
                    scheduleRespawn(kart);
                }
            }
        });
    }

    requestAnimationFrame(animateKarts);
}

/* ==========================================================================
   AUTRES FONCTIONS
   ========================================================================== */

function startGreenShellAnimation() {
    const shellElement = document.getElementById(greenShellConfig.elementId);
    if (!shellElement) return;

    setInterval(() => {
        greenShellConfig.currentFrame++;
        if (greenShellConfig.currentFrame > greenShellConfig.totalFrames) {
            greenShellConfig.currentFrame = 1;
        }
        const newPath = `static/img/${greenShellConfig.folder}/${greenShellConfig.baseName}${greenShellConfig.currentFrame}.png`;
        shellElement.src = newPath;
    }, greenShellConfig.speed);
}

function showLogo() {
    const fadeElements = document.querySelectorAll('.fade-in');
    fadeElements.forEach(el => {
        setTimeout(() => {
            el.classList.add('visible');
        }, 100);
    });
}

document.addEventListener('DOMContentLoaded', () => {
    console.log("🏎️ MK Reset Banner : Lissage de vitesse activé.");
    initCharacters();
    requestAnimationFrame(animateKarts);
    startGreenShellAnimation();
    showLogo();
});
