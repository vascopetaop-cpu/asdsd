let currentPage = 'main';
let playerData = {};
let config = {};
let pendingPurchase = null;
let Locales = {};
let currentUIStyle = 'classic'; // This is just in case you put the wrong value in config, it will default to classic
let activeFilters = {
    items: 'all',
    vehicles: 'all',
    weapons: 'all',
    mlos: 'all'
};
let container, diamondsCount, confirmModal, loadingOverlay;
let filterEventListenersAttached = false;
let testDrivePosition = 'bottom-right'; // This is just in case you put the wrong value in config, it will default to bottom-right
document.addEventListener('DOMContentLoaded', function() {
    initializeDOM();
    setupEventListeners();
});

function initializeDOM() {
    if (currentUIStyle === 'modern') {
        container = document.getElementById('modern-ui');
        diamondsCount = document.getElementById('diamonds-count-modern');
    } else {
        container = document.getElementById('classic-ui');
        diamondsCount = document.getElementById('diamonds-count-classic');
    }
    
    confirmModal = document.getElementById('confirm-modal');
    loadingOverlay = document.getElementById('loading-overlay');
}

function translate(key, defaultValue = '') {
    if (!Locales[key]) {
        console.log(`Translation key "${key}" not found. Using default value.`);
    }
    return Locales[key] || defaultValue || key;
}
function applyTranslations() {
    document.querySelectorAll('[data-translate]').forEach(el => {
        const key = el.getAttribute('data-translate');
        el.textContent = translate(key);
    });
    
    document.querySelectorAll('[data-translate-placeholder]').forEach(el => {
        const key = el.getAttribute('data-translate-placeholder');
        el.placeholder = translate(key);
    });
    
    document.querySelectorAll('[data-translate-value]').forEach(el => {
        const key = el.getAttribute('data-translate-value');
        el.value = translate(key);
    });
}
function switchUIStyle(style) {
    const classicUI = document.getElementById('classic-ui');
    const modernUI = document.getElementById('modern-ui');
    
    classicUI.classList.add('hidden');
    modernUI.classList.add('hidden');
    
    if (style === 'modern') {
        modernUI.classList.remove('hidden');
        currentUIStyle = 'modern';
        container = modernUI;
        diamondsCount = document.getElementById('diamonds-count-modern');
    } else {
        classicUI.classList.remove('hidden');
        currentUIStyle = 'classic';
        container = classicUI;
        diamondsCount = document.getElementById('diamonds-count-classic');
    }
    
    setupEventListeners();
    
    loadPageContent(currentPage);
    
    if (playerData.diamonds !== undefined) {
        updateDiamonds(playerData.diamonds);
    }
}

function setupEventListeners() {
    const activeContainer = currentUIStyle === 'modern' ? 
        document.getElementById('modern-ui') : 
        document.getElementById('classic-ui');
    
    const navButtons = activeContainer.querySelectorAll('.nav-btn');
    navButtons.forEach(btn => {
        btn.removeEventListener('click', handleNavClick);
        btn.addEventListener('click', handleNavClick);
    });

    document.removeEventListener('keydown', handleKeyDown);
    document.addEventListener('keydown', handleKeyDown);

    const soundsToggle = activeContainer.querySelector('#sounds-toggle-' + currentUIStyle);
    const animationsToggle = activeContainer.querySelector('#animations-toggle-' + currentUIStyle);

    if (soundsToggle) {
        soundsToggle.removeEventListener('change', handleSoundsToggle);
        soundsToggle.addEventListener('change', handleSoundsToggle);
    }

    if (animationsToggle) {
        animationsToggle.removeEventListener('change', handleAnimationsToggle);
        animationsToggle.addEventListener('change', handleAnimationsToggle);
    }
}

function handleNavClick(e) {
    const page = e.currentTarget.dataset.page;
    switchPage(page);
    playSound('SELECT');
}

function handleKeyDown(e) {
    if (e.key === 'Escape') {
        if (!confirmModal.classList.contains('hidden')) {
            closeConfirmModal();
        } else {
            closeMenu();
        }
    }
}

function handleSoundsToggle(e) {
    config.uiSettings.enableSounds = e.target.checked;
    if (e.target.checked) playSound('SELECT');
}

function handleAnimationsToggle(e) {
    config.uiSettings.enableAnimations = e.target.checked;
    document.body.style.setProperty('--animation-speed', e.target.checked ? '1' : '0');
}

function switchPage(page) {
    if (page !== 'tebex') {
        const activeContainer = currentUIStyle === 'modern' ? 
            document.getElementById('modern-ui') : 
            document.getElementById('classic-ui');
        
        const navButtons = activeContainer.querySelectorAll('.nav-btn');
        
        navButtons.forEach(btn => {
            btn.classList.toggle('active', btn.dataset.page === page);
        });

        const pageId = `${page}-page-${currentUIStyle}`;
        const pages = activeContainer.querySelectorAll('.page');
        pages.forEach(p => p.classList.remove('active'));

        const activePage = document.getElementById(pageId);
        if (activePage) activePage.classList.add('active');

        if (currentUIStyle === 'modern') {
            updateModernPageTitle(page);
        }

        currentPage = page;
        loadPageContent(page);

        setTimeout(() => {
            setupSearchAndFilter();
        }, 50);
    }
}

function updateModernPageTitle(page) {
    const pageTitle = document.getElementById('page-title');
    const pageSubtitle = document.getElementById('page-subtitle');
    
    if (pageTitle && pageSubtitle) {
        const titles = {
            'main': {title: translate('title_welcome', 'Welcome to VIP System'), subtitle: translate('title_manage_benefits', 'Manage your VIP benefits and purchases')},
            'tiers': {title: translate('title_tiers', 'VIP Tiers'), subtitle: translate('title_unlock_benefits', 'Unlock exclusive benefits with VIP tiers')},
            'items': {title: translate('title_items', 'VIP Items'), subtitle: translate('title_exclusive_items', 'Exclusive items available for purchase with diamonds')},
            'vehicles': {title: translate('title_vehicles', 'VIP Vehicles'), subtitle: translate('title_premium_vehicles', 'Premium vehicles for VIP members')},
            'weapons': {title: translate('title_weapons', 'VIP Weapons'), subtitle: translate('title_exclusive_weapons', 'Exclusive weapons with enhanced features')},
            'money': {title: translate('title_money', 'Exchange Diamonds'), subtitle: translate('title_convert_diamonds', 'Convert your diamonds to in-game money')},
            'mlos': {title: translate('title_mlos', 'VIP MLOs'), subtitle: translate('title_exclusive_mlos', 'Exclusive MLOs available for VIP members')},
            'settings': {title: translate('title_settings', 'Settings & History'), subtitle: translate('title_manage_preferences', 'Manage your preferences and view purchase history')}
        };
        
        if (titles[page]) {
            pageTitle.textContent = titles[page].title;
            pageSubtitle.textContent = titles[page].subtitle;
        }
    }
}

function loadTiers() {
    const tiersGridId = currentUIStyle === 'modern' ? 'tiers-grid-modern' : 'tiers-grid-classic';
    const tiersGrid = document.getElementById(tiersGridId);
    tiersGrid.innerHTML = '';

    if (!config.vipTiers) return;

    config.vipTiers.forEach((tier, index) => {
        const tierCard = createTierCard(tier, index);
        tiersGrid.appendChild(tierCard);
    });
}

function createTierCard(tier, index) {
    const card = document.createElement('div');
    card.className = 'tier-card';
    card.style.borderColor = tier.color;
    
    card.innerHTML = `
        <div class="tier-header" style="background: ${tier.color}">
            <h3>${tier.label}</h3>
            <div class="tier-price">
                <i class="fas fa-gem"></i>
                <span>${formatNumber(tier.price)}</span>
            </div>
        </div>
        <div class="tier-body">
            <div class="tier-content">
                <div class="tier-duration">
                    <i class="fas fa-calendar-alt"></i>
                    <span>${tier.duration} ${translate('tier_duration', 'days')}</span>
                </div>
                <ul class="tier-benefits">
                    ${tier.benefits.map(benefit => `<li>${benefit}</li>`).join('')}
                </ul>
            </div>
            <div class="tier-footer">
                <button class="buy-tier-btn" onclick="purchaseTier(${index})">
                    ${translate('purchase_tier', 'Purchase Tier')}
                </button>
            </div>
        </div>
    `;

    return card;
}

function purchaseTier(index) {
    const tier = config.vipTiers[index];
    if (!tier) return;
    
    showLoading();
    playSound('SELECT');
    
    setTimeout(() => {
        fetch(`https://mg-vipsystem/purchaseTier`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({ index })
        })
        .then(response => response.json())
        .then(data => {
            hideLoading();
            if (data.success) {
                playSound('SUCCESS');
            } else {
                playSound('ERROR');
            }
        })
        .catch(error => {
            hideLoading();
            playSound('ERROR');
            console.error('Error:', error);
        });
        
        setTimeout(() => {
            hideLoading();
        }, 1000); 
    }, 500); 
    
}

function loadPageContent(page) {
    switch(page) {
        case 'tiers':
            loadTiers();
            break;
        case 'items':
            loadItems();
            break;
        case 'vehicles':
            loadVehicles();
            break;
        case 'weapons':
            loadWeapons();
            break;
        case 'money':
            loadMoneyExchange();
            break;
        case 'settings':
            loadSettings();
            break;
        case 'main':
            loadMainPage();
            break;
    }
}
function setupSearchAndFilter() {
    const searchInputs = document.querySelectorAll('.search-input');
    searchInputs.forEach(input => {
        input.oninput = null;
        input.addEventListener('input', handleSearchInput);
    });
    
    const filterButtons = document.querySelectorAll('.filter-btn');
    filterButtons.forEach(btn => {
        btn.onclick = null;
        btn.addEventListener('click', handleFilterButtonClick);
    });
    
    if (!filterEventListenersAttached) {
        document.addEventListener('click', handleClickOutsideFilters);
        filterEventListenersAttached = true;
    }
}
function handleSearchInput(e) {
    const searchTerm = e.target.value.toLowerCase();
    const searchType = e.target.dataset.search;
    filterItems(searchType, searchTerm);
}
function handleFilterButtonClick(e) {
    e.stopPropagation();
    const filterType = e.currentTarget.dataset.filterType;
    const optionsContainer = e.currentTarget.nextElementSibling;
    
    document.querySelectorAll('.filter-options').forEach(container => {
        if (container !== optionsContainer && container.classList.contains('show')) {
            container.classList.remove('show');
        }
    });
    
    optionsContainer.classList.toggle('show');
    
    if (optionsContainer.children.length === 0) {
        populateFilterOptions(filterType, optionsContainer);
    }
}
function handleClickOutsideFilters(e) {
    if (!e.target.closest('.filter-dropdown')) {
        document.querySelectorAll('.filter-options').forEach(container => {
            container.classList.remove('show');
        });
    }
}
function populateFilterOptions(type, container) {
    const allOption = document.createElement('button');
    allOption.className = `filter-option ${activeFilters[type] === 'all' ? 'active' : ''}`;
    allOption.textContent = translate('filter_all', 'All');
    allOption.dataset.value = 'all';
    allOption.addEventListener('click', () => applyFilter(type, 'all', allOption));
    container.appendChild(allOption);
    
    const filters = config[`${type}Filters`];
    if (filters) {
        for (const [key, label] of Object.entries(filters)) {
            const option = document.createElement('button');
            option.className = `filter-option ${activeFilters[type] === key ? 'active' : ''}`;
            option.textContent = label;
            option.dataset.value = key;
            option.addEventListener('click', () => applyFilter(type, key, option));
            container.appendChild(option);
        }
    }
}

function applyFilter(type, value, clickedOption) {
    activeFilters[type] = value;
    const options = clickedOption.parentElement;
    options.querySelectorAll('.filter-option').forEach(opt => {
        opt.classList.remove('active');
    });
    clickedOption.classList.add('active');
    
    const searchInput = document.querySelector(`.search-input[data-search="${type}"]`);
    filterItems(type, searchInput.value.toLowerCase());
    
    options.classList.remove('show');
}

function filterItems(type, searchTerm) {
    let gridId;
    
    if (currentUIStyle === 'modern') {
        gridId = `${type}-grid-modern`;
    } else {
        gridId = `${type}-grid-classic`;
    }
    
    const grid = document.getElementById(gridId);
    const itemsToFilter = grid.querySelectorAll('.item-card');
    const activeFilter = activeFilters[type];
    
    itemsToFilter.forEach(item => {
        const name = item.querySelector('.item-name').textContent.toLowerCase();
        const description = item.querySelector('.item-description').textContent.toLowerCase();
        const itemFilter = item.dataset.filter;
        const matchesSearch = name.includes(searchTerm) || description.includes(searchTerm);
        const matchesFilter = activeFilter === 'all' || itemFilter === activeFilter;
        if (matchesSearch && matchesFilter) {
            item.style.display = 'block';
        } else {
            item.style.display = 'none';
        }
    });
}

function closeMenu() {
    container.classList.add('hidden');
    fetch(`https://mg-vipsystem/closeMenu`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({})
    });
}

function playSound(sound) {
    if (config.uiSettings && config.uiSettings.enableSounds) {
        fetch(`https://mg-vipsystem/playSound`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({ sound })
        });
    }
}

function showLoading() {
    loadingOverlay.classList.remove('hidden');
}

function hideLoading() {
    loadingOverlay.classList.add('hidden');
}

function updateDiamonds(amount) {
    if (!diamondsCount) return;
    
    diamondsCount.textContent = formatNumber(amount);
    
    diamondsCount.style.transform = 'scale(1.2)';
    diamondsCount.style.color = '#64ffda';
    
    setTimeout(() => {
        diamondsCount.style.transform = 'scale(1)';
        diamondsCount.style.color = '#ffffff';
    }, 300);
}

function formatNumber(num) {
    return new Intl.NumberFormat().format(num);
}

function redeemDiamonds() {
    const transactionIdInput = currentUIStyle === 'modern' ? 
        document.getElementById('transaction-id-modern') : 
        document.getElementById('transaction-id-classic');
    
    const transactionId = transactionIdInput.value.trim();
    
    if (!transactionId) {
        return;
    }

    showLoading();
    playSound('SELECT');

    fetch(`https://mg-vipsystem/redeemDiamonds`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({ transactionId })
    })
    .then(response => response.json())
    .then(data => {
        hideLoading();
        if (data.success) {
            transactionIdInput.value = '';
        }
    })
    .catch(error => {
        hideLoading();
        console.error('Error:', error);
    });
}

function loadMainPage() {
    if (currentUIStyle === 'classic') {
        const tierName = document.getElementById('tier-name-classic');
        const tierBenefits = document.getElementById('tier-benefits-classic');
        if (config.tiersEnabled) {
            const vipTier = config.vipTiers.find(t => t.id === playerData.vipTier);
            if (vipTier) {
                tierName.textContent = vipTier.label;
                tierBenefits.textContent = vipTier.benefits.join(' • ');
                tierName.style.color = vipTier.color;
            } else {
                tierName.textContent = translate('no_vip_tier', 'No VIP Tier');
                tierBenefits.textContent = translate('purchase_vip_tier', 'Purchase a VIP Tier to get VIP benefits');
                tierName.style.color = '#ffffff';
            }
        } else {
            const tierSection = document.getElementById('welcome-section-classic');
            if (tierSection) {
                tierSection.style.display = 'none'; 
            }
        }
        const featuredContainer = document.getElementById('featured-offers-classic');
        featuredContainer.innerHTML = '';

        if (config.featuredOffers && config.featuredOffersEnabled) {
            config.featuredOffers.forEach(offer => {
                if (offer.active) {
                    const offerEl = createFeaturedOffer(offer);
                    featuredContainer.appendChild(offerEl);
                }
            });
        }
    } else {
        const vipTier = config.vipTiers.find(t => t.id === playerData.vipTier);
        if (config.tiersEnabled) {
            const vipBadge = document.getElementById('vip-tier-badge');
            if (vipBadge && vipTier) {
                vipBadge.textContent = vipTier.label;
                vipBadge.className = 'vip-tier-badge';
                vipBadge.style.background = playerData.vipTier.color;
            }
        } else {
            const vipBadge = document.getElementById('vip-tier-badge');
            if (vipBadge) {
                vipBadge.style.display = 'none';
            }
        }

        const featuredContainer = document.getElementById('featured-offers-modern');
        featuredContainer.innerHTML = '';

        if (config.featuredOffers && config.featuredOffersEnabled) {
            config.featuredOffers.forEach(offer => {
                if (offer.active) {
                    const offerEl = createFeaturedOffer(offer);
                    featuredContainer.appendChild(offerEl);
                }
            });
        }

        const benefitsList = document.getElementById('benefits-list-modern');
        if (benefitsList) {
            if (vipTier && vipTier.benefits) {
                benefitsList.innerHTML = vipTier.benefits.map(benefit => 
                    `<div class="benefit-item">• ${benefit}</div>`
                ).join('');
            } else {
                benefitsList.textContent = translate('purchase_vip_tier', 'Purchase a VIP Tier to get VIP benefits!');
            }
        }
    }
}
function openTebexStore() {
    playSound('SELECT');
    showLoading(); 
    setTimeout(() => {
    window.invokeNative("openUrl", config.tebexLink);
        
        setTimeout(() => {
            hideLoading();
        }, 1000); 
    }, 500); 
}

function createFeaturedOffer(offer) {
    const div = document.createElement('div');
    
    if (currentUIStyle === 'modern') {
        div.className = 'featured-card';
        div.innerHTML = `

            <h2>${offer.name}</h2>
            <div class="featured-description">${offer.description}</div>
        `;
    } else {
        div.className = 'featured-offer';
        div.innerHTML = `
            <h2>${offer.name}</h2>
            <p>${offer.description}</p>
        `;
    }
    
    return div;
}

function loadItems() {
    const itemsGridId = currentUIStyle === 'modern' ? 'items-grid-modern' : 'items-grid-classic';
    const itemsGrid = document.getElementById(itemsGridId);
    itemsGrid.innerHTML = '';

    if (!config.items) return;

    config.items.forEach((item, index) => {
        const itemCard = createItemCard(item, index, 'item');
        itemsGrid.appendChild(itemCard);
    });
}

function loadVehicles() {
    const vehiclesGridId = currentUIStyle === 'modern' ? 'vehicles-grid-modern' : 'vehicles-grid-classic';
    const vehiclesGrid = document.getElementById(vehiclesGridId);
    vehiclesGrid.innerHTML = '';

    if (!config.vehicles) return;

    config.vehicles.forEach((vehicle, index) => {
        const vehicleCard = createItemCard(vehicle, index, 'vehicle');
        vehiclesGrid.appendChild(vehicleCard);
    });
}

function loadWeapons() {
    const weaponsGridId = currentUIStyle === 'modern' ? 'weapons-grid-modern' : 'weapons-grid-classic';
    const weaponsGrid = document.getElementById(weaponsGridId);
    weaponsGrid.innerHTML = '';

    if (!config.weapons) return;

    config.weapons.forEach((weapon, index) => {
        const weaponCard = createItemCard(weapon, index, 'weapon');
        weaponsGrid.appendChild(weaponCard);
    });
}
function loadMlos(mloList, filters, style) {
    const gridId = style === 'modern' ? 'mlos-grid-modern' : 'mlos-grid-classic';
    const grid = document.getElementById(gridId);
    grid.innerHTML = '';
    let imagePath = config.defaultImage;
    const buttonText = translate('buy', 'Buy');
    if (!config.mlos) return;
    mloList.forEach((mlo, index) => {
        const card = document.createElement('div');
        card.className = 'item-card';
        if (mlo.image) {
            if (mlo.image.startsWith('http://') || mlo.image.startsWith('https://')) {
                imagePath = mlo.image;
            } else {
                imagePath = `images/mlos/${mlo.image}`;
            }
        }
        card.innerHTML = `
            <div class="item-image">
                <img src="${imagePath}" alt="${mlo.name}">
            </div>
            <div class="item-info">
                <h3 class="item-name">${mlo.name}</h3>
                <p class="item-description">${mlo.description || ''}</p>
                <div class="item-footer">
                    <div class="item-price">
                        <i class="fas fa-gem"></i> ${mlo.price}
                    </div>
                    <button class="buy-btn" onclick="showPurchaseConfirm(${index}, 'mlo')">
                        <span>${buttonText}</span>
                    </button>
                </div>
            </div>
        `;
        grid.appendChild(card);
    });
}

function purchaseMlo(index) {
    const mlo = config.mlos[index];
    if (!mlo) return;

    showLoading();
    playSound('SELECT');
    
    setTimeout(() => {
        fetch(`https://mg-vipsystem/purchaseMlo`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({ index })
        })
        .then(response => response.json())
        .then(data => {
            hideLoading();
            if (data.success) {
                playSound('SUCCESS');
            } else {
                playSound('ERROR');
            }
        })
        .catch(error => {
            hideLoading();
            playSound('ERROR');
            console.error('Error:', error);
        });
        
        setTimeout(() => {
            hideLoading();
        }, 1000); 
    }, 500); 
}

function startTestDrive(index) {
    playSound('SELECT');
    fetch(`https://mg-vipsystem/testDrive`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ index })
    });
}

function createItemCard(item, index, type) {
    const card = document.createElement('div');
    card.className = 'item-card';
    card.dataset.filter = item.filter || 'all';
    const imgFolder = {
        item: 'items',
        vehicle: 'vehicles',
        weapon: 'weapons',
        tier: 'tiers'
    };
    let buttonsHTML = `
        <button class="buy-btn" onclick="showPurchaseConfirm(${index}, '${type}')">
            ${translate('buy', 'Buy')}
        </button>
    `;

    if (type === 'vehicle' && config.testDriveEnabled) {
        buttonsHTML += `
            <button class="test-btn" onclick="startTestDrive(${index})">
                ${translate('test_drive', 'Test Drive')}
            </button>
        `;
    }
    let imagePath = config.defaultImage;
    if (item.image) {
        if (item.image.startsWith('http://') || item.image.startsWith('https://')) {
            imagePath = item.image;
        } else {
            imagePath = `images/${imgFolder[type]}/${item.image}`;
        }
    }
    card.innerHTML = `
        <div class="item-image" >
            <img src="${imagePath}">
        </div>
        <div class="item-info">
            <h3 class="item-name">${item.name}</h3>
            <p class="item-description">${item.description || ''}</p>
            <div class="item-footer">
                <div class="item-price">
                    <i class="fas fa-gem"></i>
                    <span>${formatNumber(item.price)}</span>
                </div>
                <div class="item-buttons">
                    ${buttonsHTML}
                </div>
            </div>
        </div>
    `;

    return card;
}

function loadMoneyExchange() {
    const moneyGridId = currentUIStyle === 'modern' ? 'money-grid-modern' : 'money-grid-classic';
    const moneyGrid = document.getElementById(moneyGridId);
    moneyGrid.innerHTML = '';

    if (!config.moneyExchange) return;

    config.moneyExchange.forEach((exchange, index) => {
        const moneyCard = createMoneyCard(exchange, index);
        moneyGrid.appendChild(moneyCard);
    });
}

function createMoneyCard(exchange, index) {
    const card = document.createElement('div');
    card.className = 'money-card';
    card.onclick = () => showPurchaseConfirm(index, 'money');

    card.innerHTML = `
        <div class="money-amount">${exchange.label}</div>
        <div class="money-price">
            <i class="fas fa-gem"></i>
            <span>${formatNumber(exchange.price)} ${translate('diamonds', 'Diamonds')}</span>
        </div>
    `;

    return card;
}
function clearPurchaseHistory() {
    playSound('SELECT');

    fetch(`https://mg-vipsystem/clearPurchaseHistory`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({})
    });
    playerData.purchaseHistory = [];
    loadSettings();
}

function loadSettings() {
    const historyListId = currentUIStyle === 'modern' ? 'history-list-modern' : 'history-list-classic';
    const historyList = document.getElementById(historyListId);

    const clearBtnClassic = document.getElementById('historyClearBTN-classic');
    const clearBtnModern = document.getElementById('historyClearBTN-modern');

    if (clearBtnClassic) clearBtnClassic.classList.add('hidden');
    if (clearBtnModern) clearBtnModern.classList.add('hidden');

    if (historyList) {
        historyList.innerHTML = '';

        if (playerData.purchaseHistory && playerData.purchaseHistory.length > 0) {
            if (currentUIStyle === 'modern' && clearBtnModern) {
                clearBtnModern.classList.remove('hidden');
            } else if (currentUIStyle === 'classic' && clearBtnClassic) {
                clearBtnClassic.classList.remove('hidden');
            }

            playerData.purchaseHistory.forEach(entry => {
                const historyItem = document.createElement('div');
                historyItem.className = 'history-card';

                const data = JSON.parse(entry.purchase_data || '{}');

                let imagePath = config.defaultImage;
                switch (entry.item_type) {
                    case 'item':
                        const itemConfig = config.items.find(item => item.item === data.item);
                        if (itemConfig && itemConfig.image) {
                            if (itemConfig.image.startsWith('http://') || itemConfig.image.startsWith('https://')) {
                                imagePath = itemConfig.image;
                            } else {
                                imagePath = `images/items/${itemConfig.image}`;
                            }
                        }
                        break;
                    case 'vehicle':
                        const vehicleConfig = config.vehicles.find(vehicle => vehicle.model === data.model);
                        if (vehicleConfig && vehicleConfig.image) {
                            if (vehicleConfig.image.startsWith('http://') || vehicleConfig.image.startsWith('https://')) {
                                imagePath = vehicleConfig.image;
                            } else {
                                imagePath = `images/vehicles/${vehicleConfig.image}`;
                            }
                        }
                        break;
                    case 'weapon':
                        const weaponConfig = config.weapons.find(weapon => weapon.weapon === data.weapon);
                        if (weaponConfig && weaponConfig.image) {
                            if (weaponConfig.image.startsWith('http://') || weaponConfig.image.startsWith('https://')) {
                                imagePath = weaponConfig.image;
                            } else {
                                imagePath = `images/weapons/${weaponConfig.image}`;
                            }
                        }
                        break;
                    case 'money':
                        imagePath = `images/cash.png`;
                        break;
                    case 'tier':
                        imagePath = `images/tiers/${data.id}.png`; 
                        break;
                    case 'mlo':
                        const mloConfig = config.mlos.find(mlo => mlo.mloId === data.mlo);
                        if (mloConfig && mloConfig.image) {
                            if (mloConfig.image.startsWith('http://') || mloConfig.image.startsWith('https://')) {
                                imagePath = mloConfig.image;
                            } else {
                                imagePath = `images/mlos/${mloConfig.image}`;
                            }
                        }
                        break;
                
                }
                historyItem.innerHTML = `
                    <div class="history-card-image">
                        <img src="${imagePath}">
                    </div>
                    <div class="history-card-info">
                        <div class="history-card-name">${entry.item_name}</div>
                        <div class="history-card-date">${new Date(entry.created_at).toLocaleDateString()}</div>
                        <div class="history-card-price">${formatNumber(entry.diamonds_cost)} ${translate('diamonds', 'Diamonds')}</div>
                    </div>
                `;

                historyList.appendChild(historyItem);
            });
        } else {
            historyList.innerHTML = `<div class="no-history">${translate('no_history', 'No purchase history available')}</div>`;
        }
    }
}

function showPurchaseConfirm(index, type) {
    let item;
    
    switch(type) {
        case 'item':
            item = config.items[index];
            break;
        case 'vehicle':
            item = config.vehicles[index];
            break;
        case 'weapon':
            item = config.weapons[index];
            break;
        case 'money':
            item = config.moneyExchange[index]; 
            break;
        case 'mlo':
            item = config.mlos[index];
            break;
        default:
            return;
    }
    
    if (!item) return;
    
    pendingPurchase = { index, type, item };
    
    const img = document.getElementById('confirm-image');
    if (img) {
        img.classList.remove('hidden');
        if (item.image) {
            if (item.image.startsWith('http://') || item.image.startsWith('https://')) {
                img.src = item.image;
            } else {
                if (type !== 'money') {
                    img.src = `images/${type}s/${item.image}`;
                } else {
                    img.src = `images/cash.png`;
                }
            }
        } else {
            img.src = config.defaultImage;
        }
    }

    document.getElementById('confirm-name').textContent = item.name || item.label;
    document.getElementById('confirm-description').textContent = item.description || '';
    document.getElementById('confirm-price-amount').textContent = formatNumber(item.price);
    
    confirmModal.classList.remove('hidden');
    playSound('SELECT');
}

function closeConfirmModal() {
    confirmModal.classList.add('hidden');
    pendingPurchase = null;
}

function confirmPurchase() {
    if (!pendingPurchase) return;
    
    const purchaseData = {
        type: pendingPurchase.type,
        index: pendingPurchase.index
    };
    
    showLoading();
    closeConfirmModal();
    pendingPurchase = null; 
    if (purchaseData.type === 'money') {
        fetch(`https://mg-vipsystem/exchangeMoney`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify(purchaseData)
        })
        .then(response => response.json())
        .then(data => {
            hideLoading();
            if (data.success) {
                playSound('SUCCESS');
            } else {
                playSound('ERROR');
            }
        })
        .catch(error => {
            hideLoading();
            playSound('ERROR');
            console.error('Error:', error);
        });
    } else if (purchaseData.type === 'item') {
        fetch(`https://mg-vipsystem/purchaseItem`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify(purchaseData)
        })
        .then(response => response.json())
        .then(data => {
            hideLoading();
            if (data.success) {
                playSound('SUCCESS');
            } else {
                playSound('ERROR');
            }
        })
        .catch(error => {
            hideLoading();
            playSound('ERROR');
            console.error('Error:', error);
        });
    } else if (purchaseData.type === 'vehicle') {
        fetch(`https://mg-vipsystem/purchaseVehicle`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify(purchaseData)
        })
        .then(response => response.json())
        .then(data => {
            hideLoading();
            if (data.success) {
                playSound('SUCCESS');
            } else {
                playSound('ERROR');
            }
        })
        .catch(error => {
            hideLoading();
            playSound('ERROR');
            console.error('Error:', error);
        });
    } else if (purchaseData.type === 'weapon') {
        fetch(`https://mg-vipsystem/purchaseWeapon`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify(purchaseData)
        })
        .then(response => response.json())
        .then(data => {
            hideLoading();
            if (data.success) {
                playSound('SUCCESS');
            } else {
                playSound('ERROR');
            }
        })
        .catch(error => {
            hideLoading();
            playSound('ERROR');
            console.error('Error:', error);
        });

    } else if (purchaseData.type === 'mlo') {
        fetch(`https://mg-vipsystem/purchaseMlo`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify(purchaseData)
        })
        .then(response => response.json())
        .then(data => {
            hideLoading();
            if (data.success) {
                playSound('SUCCESS');
            } else {
                playSound('ERROR');
            }
        })
        .catch(error => {
            hideLoading();
            playSound('ERROR');
            console.error('Error:', error);
        });
    }

}


function exchangeMoney(index) {
    const exchange = config.moneyExchange[index];
    if (!exchange) return;
    
    showLoading();
    playSound('SELECT');
    
    fetch(`https://mg-vipsystem/exchangeMoney`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({ index })
    })
    .then(response => response.json())
    .then(data => {
        hideLoading();
        if (data.success) {
            playSound('SUCCESS');
        } else {
            playSound('ERROR');
        }
    })
    .catch(error => {
        hideLoading();
        playSound('ERROR');
        console.error('Error:', error);
    });
}
function updateServerLogo() {
    const classicLogo = document.getElementById('classic-logo');
    const modernLogo = document.getElementById('modern-logo');
    
    if (config && config.ServerLogo) {
        classicLogo.src = config.ServerLogo;
        modernLogo.src = config.ServerLogo;
        
        classicLogo.classList.add('visible');
        modernLogo.classList.add('visible');
    } else {
        classicLogo.classList.remove('visible');
        modernLogo.classList.remove('visible');
    }
}
let testDriveInterval;

function showTestDrive(duration, finishKey) {
    const container = document.getElementById('testdrive-ui');
    const timerEl = document.getElementById('testdrive-timer');
    const keyEl = document.getElementById('testdrive-key');

    container.classList.remove(
        'testdrive-top-left', 'testdrive-top-right',
        'testdrive-bottom-left', 'testdrive-bottom-right',
        'testdrive-center-left', 'testdrive-center-right',
        'testdrive-center-top', 'testdrive-center-bottom'
    );
    container.classList.add('testdrive-' + testDrivePosition);
    
    keyEl.textContent = finishKey;
    keyEl.className = "key-style";
    const pressPart1 = container.querySelector('[data-translate="press_key_part1"]');
    const pressPart2 = container.querySelector('[data-translate="press_key_part2"]');
    
    if (pressPart1) pressPart1.textContent = translate('press_key_part1', 'Press');
    if (pressPart2) pressPart2.textContent = translate('press_key_part2', 'to end');
    container.style.display = 'block';

    let remaining = duration;
    clearInterval(testDriveInterval);
    updateTimer();

    testDriveInterval = setInterval(() => {
        remaining--;
        updateTimer();

        if (remaining <= 0) {
            clearInterval(testDriveInterval);
        }
    }, 1000);

    function updateTimer() {
        const minutes = String(Math.floor(remaining / 60)).padStart(2, '0');
        const seconds = String(remaining % 60).padStart(2, '0');
        timerEl.textContent = `${minutes}:${seconds}`;
    }
}

function endTestDrive() {
    const container = document.getElementById('testdrive-ui');
    container.style.display = 'none';
    clearInterval(testDriveInterval);
}
window.addEventListener('message', function(event) {
    const data = event.data;
    switch(data.action) {

        case 'openMenu':
            playerData = data.playerData || {};
            config = data.config || {};
            Locales = data.locales || {};
            testDrivePosition = config.uiSettings.testDriveInfoPosition || 'bottom-right';
            applyTranslations();
            updateServerLogo();
            ['tiers', 'items', 'vehicles', 'weapons', 'money', 'mlos'].forEach(page => {
                const enabledKey = {
                    tiers: 'tiersEnabled',
                    items: 'vipItemsEnabled',
                    vehicles: 'vipVehiclesEnabled',
                    weapons: 'vipWeaponsEnabled',
                    money: 'moneyExchangeEnabled',
                    mlos: 'mloEnabled'
                }[page];

                if (config[enabledKey] === false) {
                    const btnClassic = document.querySelector(`#classic-ui .nav-btn[data-page="${page}"]`);
                    const btnModern = document.querySelector(`#modern-ui .nav-btn[data-page="${page}"]`);
                    if (btnClassic) btnClassic.style.display = 'none';
                    if (btnModern) btnModern.style.display = 'none';
                }
            });
            if (data.style) {
                switchUIStyle(data.style);
            } else {
                switchUIStyle('classic'); 
            }
            
            container.classList.remove('hidden');
            updateDiamonds(playerData.diamonds || 0);
            loadMainPage();
            if (config.mloEnabled) {
                loadMlos(config.mlos, config.mloFilters, data.style);
            }
            break;
        case 'updatePlayerData':
            playerData = data.data;
            updateDiamonds(playerData.diamonds || 0);
            loadMainPage();
            break;
        case 'updateDiamonds':
            playerData.diamonds = data.diamonds;
            updateDiamonds(data.diamonds);
            break;
            
        case 'updateVipTier':
            playerData.vipTier = data.vipTier;
            loadMainPage();
            break;
            
        case 'closeMenu':
            container.classList.add('hidden');
            break;
        case 'startTestDrive':
            showTestDrive(data.duration, data.finishKey);
            break;
        case 'endTestDrive':
            endTestDrive();
            break;
    }
});