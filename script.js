let countdownInterval = null;

window.addEventListener('message', function(event) {
    let data = event.data;

    if (data.action === "open") {
        document.body.style.display = "block";
        buildArmoryList(data.items, data.price);
        startTimer(data.cooldown);
    } else if (data.action === "update") {
        buildArmoryList(data.items, 1);
        startTimer(data.cooldown);
    }
});

function buildArmoryList(items, price) {
    const container = document.getElementById('item-list');
    container.innerHTML = '';

    for (let itemKey in items) {
        let item = items[itemKey];
        let imageSrc = `nui://qb-inventory/html/images/${itemKey}.png`;
        let isOutOfStock = item.current <= 0;

        let card = `
            <div class="minister-card">
                <span class="item-title">${item.label}</span>
                <div class="img-container">
                    <img src="${imageSrc}" alt="${item.label}" onerror="this.src='https://via.placeholder.com/64?text=Item';">
                </div>
                <div class="item-stock">المتبقي لك: <span>${item.current} / ${item.max}</span></div>
                
                <div class="minister-qty">
                    <button class="m-qty-btn" onclick="adjustQty('${itemKey}', -1, ${item.current})">-</button>
                    <input type="text" id="qty-${itemKey}" class="m-qty-val" value="${isOutOfStock ? 0 : 1}" readonly>
                    <button class="m-qty-btn" onclick="adjustQty('${itemKey}', 1, ${item.current})">+</button>
                </div>

                <button class="buy-btn-minister" id="btn-${itemKey}" onclick="claimItem('${itemKey}')" ${isOutOfStock ? 'disabled' : ''}>
                    ${isOutOfStock ? 'انتهت عهدتك اليومية' : `صرف العهدة ($${price})`}
                </button>
            </div>
        `;
        container.innerHTML += card;
    }
}

function adjustQty(itemKey, change, maxVal) {
    const input = document.getElementById(`qty-${itemKey}`);
    if (!input) return;

    let currentVal = parseInt(input.value) || 0;
    let newVal = currentVal + change;

    if (newVal >= 1 && newVal <= maxVal) {
        input.value = newVal;
    }
}

function claimItem(itemKey) {
    const input = document.getElementById(`qty-${itemKey}`);
    if (!input) return;

    let amount = parseInt(input.value) || 0;
    if (amount <= 0) return;

    fetch(`https://${GetParentResourceName()}/claimItem`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json; charset=UTF-8' },
        body: JSON.stringify({ item: itemKey, amount: amount })
    });
}

function startTimer(durationInSeconds) {
    if (countdownInterval) clearInterval(countdownInterval);

    let timer = durationInSeconds;
    const display = document.getElementById('countdown-timer');

    function updateDisplay() {
        if (timer <= 0) {
            display.textContent = "00:00:00";
            clearInterval(countdownInterval);
            return;
        }

        let hours = Math.floor(timer / 3600);
        let minutes = Math.floor((timer % 3600) / 60);
        let seconds = timer % 60;

        hours = hours < 10 ? "0" + hours : hours;
        minutes = minutes < 10 ? "0" + minutes : minutes;
        seconds = seconds < 10 ? "0" + seconds : seconds;

        display.textContent = hours + ":" + minutes + ":" + seconds;
        timer--;
    }

    updateDisplay();
    countdownInterval = setInterval(updateDisplay, 1000);
}

function closeMenu() {
    document.body.style.display = "none";
    if (countdownInterval) clearInterval(countdownInterval);
    fetch(`https://${GetParentResourceName()}/closeUI`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json; charset=UTF-8' }
    });
}

document.getElementById('close-btn').addEventListener('click', closeMenu);

window.addEventListener('keydown', function(event) {
    if (event.key === "Escape") {
        closeMenu();
    }
});