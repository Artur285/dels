// Sample warehouse properties data
const propertiesData = [
    {
        id: 1,
        title: "Modern Distribution Center",
        location: "New York, NY",
        size: "85,000 sq ft",
        type: "distribution",
        price: "$3,500,000",
        status: "available",
        image: "https://images.unsplash.com/photo-1586528116311-ad8dd3c8310d?w=800&h=600&fit=crop",
        year: 2020,
        features: ["Loading Docks", "Office Space", "Climate Controlled"]
    },
    {
        id: 2,
        title: "Industrial Storage Facility",
        location: "Los Angeles, CA",
        size: "120,000 sq ft",
        type: "storage",
        price: "$5,200,000",
        status: "available",
        image: "https://images.unsplash.com/photo-1563729784474-d77dbb933a9e?w=800&h=600&fit=crop",
        year: 2018,
        features: ["High Ceilings", "Security System", "Rail Access"]
    },
    {
        id: 3,
        title: "Manufacturing Warehouse",
        location: "Chicago, IL",
        size: "65,000 sq ft",
        type: "manufacturing",
        price: "$2,800,000",
        status: "pending",
        image: "https://images.unsplash.com/photo-1581091226825-a6a2a5aee158?w=800&h=600&fit=crop",
        year: 2019,
        features: ["Heavy Power", "Crane System", "Expansion Ready"]
    },
    {
        id: 4,
        title: "Cold Storage Facility",
        location: "Houston, TX",
        size: "95,000 sq ft",
        type: "cold-storage",
        price: "$4,100,000",
        status: "available",
        image: "https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=800&h=600&fit=crop",
        year: 2021,
        features: ["Freezer Units", "Refrigeration", "Food Grade"]
    },
    {
        id: 5,
        title: "Logistics Hub",
        location: "Miami, FL",
        size: "150,000 sq ft",
        type: "distribution",
        price: "$6,500,000",
        status: "available",
        image: "https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=800&h=600&fit=crop",
        year: 2022,
        features: ["Port Access", "Multiple Docks", "Modern Facility"]
    },
    {
        id: 6,
        title: "Flex Warehouse Space",
        location: "New York, NY",
        size: "45,000 sq ft",
        type: "storage",
        price: "$1,900,000",
        status: "available",
        image: "https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?w=800&h=600&fit=crop",
        year: 2017,
        features: ["Divisible Units", "Office Space", "Parking"]
    },
    {
        id: 7,
        title: "E-commerce Fulfillment Center",
        location: "Los Angeles, CA",
        size: "200,000 sq ft",
        type: "distribution",
        price: "$8,200,000",
        status: "available",
        image: "https://images.unsplash.com/photo-1600880292203-757bb62b4baf?w=800&h=600&fit=crop",
        year: 2023,
        features: ["Automation Ready", "High Bay", "Sortation System"]
    },
    {
        id: 8,
        title: "Regional Distribution Center",
        location: "Chicago, IL",
        size: "175,000 sq ft",
        type: "distribution",
        price: "$7,100,000",
        status: "pending",
        image: "https://images.unsplash.com/photo-1600566753190-17f0baa2a6c3?w=800&h=600&fit=crop",
        year: 2020,
        features: ["Cross Dock", "Rail Siding", "Expansion Land"]
    },
    {
        id: 9,
        title: "Bulk Storage Warehouse",
        location: "Houston, TX",
        size: "110,000 sq ft",
        type: "storage",
        price: "$3,800,000",
        status: "available",
        image: "https://images.unsplash.com/photo-1600607687644-c7171b42498b?w=800&h=600&fit=crop",
        year: 2016,
        features: ["High Clearance", "Bulk Loading", "Secure Yard"]
    },
    {
        id: 10,
        title: "Light Manufacturing Space",
        location: "Miami, FL",
        size: "55,000 sq ft",
        type: "manufacturing",
        price: "$2,400,000",
        status: "available",
        image: "https://images.unsplash.com/photo-1581092160562-40aa08e78837?w=800&h=600&fit=crop",
        year: 2019,
        features: ["Clean Room", "Office Space", "Loading Bays"]
    },
    {
        id: 11,
        title: "Food Distribution Center",
        location: "New York, NY",
        size: "90,000 sq ft",
        type: "cold-storage",
        price: "$4,500,000",
        status: "available",
        image: "https://images.unsplash.com/photo-1556912172-45b7abe8b7e1?w=800&h=600&fit=crop",
        year: 2021,
        features: ["Cold Chain", "Dry Storage", "Processing Area"]
    },
    {
        id: 12,
        title: "Last-Mile Delivery Hub",
        location: "Los Angeles, CA",
        size: "35,000 sq ft",
        type: "distribution",
        price: "$1,600,000",
        status: "available",
        image: "https://images.unsplash.com/photo-1600585154526-990dbe4eb0f3?w=800&h=600&fit=crop",
        year: 2022,
        features: ["Urban Location", "Small Vehicle Access", "Sortation"]
    }
];

// Initialize on page load
document.addEventListener('DOMContentLoaded', function() {
    initializeNavigation();
    initializeScrollAnimations();
    initializeParallax();
    
    if (document.getElementById('featuredProperties')) {
        loadFeaturedProperties();
    }
    
    if (document.getElementById('propertiesGrid')) {
        loadAllProperties();
        setupFilters();
        setupSorting();
    }
    
    if (document.getElementById('contactForm')) {
        setupContactForm();
    }
});

// Scroll-triggered animations using Intersection Observer
function initializeScrollAnimations() {
    const observerOptions = {
        threshold: 0.1,
        rootMargin: '0px 0px -50px 0px'
    };

    const observer = new IntersectionObserver(function(entries) {
        entries.forEach((entry, index) => {
            if (entry.isIntersecting) {
                entry.target.style.animationDelay = `${(index % 3) * 0.1}s`;
                entry.target.classList.add('fade-in');
                observer.unobserve(entry.target);
            }
        });
    }, observerOptions);

    // Observe feature cards
    document.querySelectorAll('.feature-card').forEach(card => {
        observer.observe(card);
    });

    // Observe property cards
    document.querySelectorAll('.property-card').forEach((card, index) => {
        card.style.animationDelay = `${(index % 3) * 0.1}s`;
        observer.observe(card);
    });

    // Observe section headers
    document.querySelectorAll('.section-header').forEach(header => {
        observer.observe(header);
    });

    // Observe stats
    document.querySelectorAll('.stat-item').forEach(stat => {
        observer.observe(stat);
    });
}

// Parallax effect for hero section
function initializeParallax() {
    const hero = document.querySelector('.hero');
    if (!hero) return;

    let ticking = false;

    function updateParallax() {
        const scrolled = window.pageYOffset;
        const rate = scrolled * 0.5;
        
        if (hero) {
            hero.style.transform = `translateY(${rate}px)`;
        }
        
        ticking = false;
    }

    window.addEventListener('scroll', function() {
        if (!ticking) {
            window.requestAnimationFrame(updateParallax);
            ticking = true;
        }
    }, { passive: true });
}

// Navigation functionality
function initializeNavigation() {
    const mobileMenuToggle = document.getElementById('mobileMenuToggle');
    const navLinks = document.querySelector('.nav-links');
    const navbar = document.querySelector('.navbar');
    
    if (mobileMenuToggle) {
        mobileMenuToggle.addEventListener('click', function() {
            navLinks.classList.toggle('active');
        });
    }
    
    // Navbar scroll effect
    let lastScroll = 0;
    window.addEventListener('scroll', function() {
        const currentScroll = window.pageYOffset;
        
        if (navbar) {
            if (currentScroll > 50) {
                navbar.classList.add('scrolled');
            } else {
                navbar.classList.remove('scrolled');
            }
        }
        
        lastScroll = currentScroll;
    }, { passive: true });
    
    // Smooth scroll for anchor links
    document.querySelectorAll('a[href^="#"]').forEach(anchor => {
        anchor.addEventListener('click', function(e) {
            e.preventDefault();
            const target = document.querySelector(this.getAttribute('href'));
            if (target) {
                target.scrollIntoView({
                    behavior: 'smooth',
                    block: 'start'
                });
            }
        });
    });
}

// Load featured properties on homepage
function loadFeaturedProperties() {
    const container = document.getElementById('featuredProperties');
    const featured = propertiesData.slice(0, 6);
    
    container.innerHTML = featured.map(property => createPropertyCard(property)).join('');
    
    // Re-initialize scroll animations for newly loaded cards
    setTimeout(() => {
        initializeScrollAnimations();
    }, 100);
}

// Load all properties on properties page
let filteredProperties = [...propertiesData];
let currentPage = 1;
const itemsPerPage = 9;

function loadAllProperties() {
    const container = document.getElementById('propertiesGrid');
    const startIndex = (currentPage - 1) * itemsPerPage;
    const endIndex = startIndex + itemsPerPage;
    const propertiesToShow = filteredProperties.slice(startIndex, endIndex);
    
    container.innerHTML = propertiesToShow.map(property => createPropertyCard(property)).join('');
    
    updateResultsCount();
    updatePagination();
    
    // Re-initialize scroll animations for newly loaded cards
    setTimeout(() => {
        initializeScrollAnimations();
    }, 100);
}

// Create property card HTML
function createPropertyCard(property) {
    const statusClass = property.status === 'available' ? 'status-available' : 'status-pending';
    const statusText = property.status === 'available' ? 'Available' : 'Pending';
    
    // Get first 3 features for display
    const displayFeatures = property.features.slice(0, 3);
    
    return `
        <div class="property-card" onclick="viewProperty(${property.id})">
            <div class="property-image-wrapper">
                <img src="${property.image}" alt="${property.title}" class="property-image" loading="lazy" onload="this.classList.add('loaded')" onerror="this.style.display='none'">
                <div class="property-image-overlay"></div>
                <div class="property-badge ${statusClass}">${statusText}</div>
            </div>
            <div class="property-content">
                <h3 class="property-title">${property.title}</h3>
                <div class="property-location">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z"></path>
                        <circle cx="12" cy="10" r="3"></circle>
                    </svg>
                    ${property.location}
                </div>
                <div class="property-details">
                    <div class="property-detail-item">
                        <svg class="property-detail-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <rect x="3" y="3" width="18" height="18" rx="2" ry="2"></rect>
                            <line x1="9" y1="3" x2="9" y2="21"></line>
                            <line x1="3" y1="9" x2="21" y2="9"></line>
                        </svg>
                        <div class="property-detail-label">Size</div>
                        <div class="property-detail-value">${property.size}</div>
                    </div>
                    <div class="property-detail-item">
                        <svg class="property-detail-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M21 16V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16z"></path>
                        </svg>
                        <div class="property-detail-label">Type</div>
                        <div class="property-detail-value">${capitalizeFirst(property.type)}</div>
                    </div>
                    <div class="property-detail-item">
                        <svg class="property-detail-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <circle cx="12" cy="12" r="10"></circle>
                            <polyline points="12 6 12 12 16 14"></polyline>
                        </svg>
                        <div class="property-detail-label">Year</div>
                        <div class="property-detail-value">${property.year}</div>
                    </div>
                </div>
                <div class="property-price">${property.price}</div>
                ${displayFeatures.length > 0 ? `
                <div class="property-features">
                    ${displayFeatures.map(feature => `<span class="property-feature-tag">${feature}</span>`).join('')}
                </div>
                ` : ''}
                <div class="property-footer">
                    <span class="property-status ${statusClass}">${statusText}</span>
                    <button class="view-btn" onclick="event.stopPropagation(); viewProperty(${property.id})">
                        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M5 12h14M12 5l7 7-7 7"></path>
                        </svg>
                        View Details
                    </button>
                </div>
            </div>
        </div>
    `;
}

// View property details
function viewProperty(id) {
    const property = propertiesData.find(p => p.id === id);
    if (property) {
        // In a real application, this would navigate to a detail page
        alert(`Property: ${property.title}\n\nLocation: ${property.location}\nSize: ${property.size}\nPrice: ${property.price}\n\nFeatures:\n${property.features.join('\n')}\n\nStatus: ${property.status}`);
    }
}

// Setup filters
function setupFilters() {
    const searchInput = document.getElementById('propertySearch');
    const locationFilter = document.getElementById('filterLocation');
    const sizeFilter = document.getElementById('filterSize');
    const typeFilter = document.getElementById('filterType');
    const priceFilter = document.getElementById('filterPrice');
    
    [searchInput, locationFilter, sizeFilter, typeFilter, priceFilter].forEach(element => {
        if (element) {
            element.addEventListener('change', applyFilters);
            element.addEventListener('input', applyFilters);
        }
    });
}

// Apply filters
function applyFilters() {
    const searchTerm = document.getElementById('propertySearch')?.value.toLowerCase() || '';
    const location = document.getElementById('filterLocation')?.value || '';
    const size = document.getElementById('filterSize')?.value || '';
    const type = document.getElementById('filterType')?.value || '';
    const price = document.getElementById('filterPrice')?.value || '';
    
    filteredProperties = propertiesData.filter(property => {
        const matchesSearch = !searchTerm || 
            property.title.toLowerCase().includes(searchTerm) ||
            property.location.toLowerCase().includes(searchTerm);
        
        const matchesLocation = !location || property.location.includes(location);
        
        const matchesType = !type || property.type === type;
        
        const matchesSize = !size || checkSizeMatch(property.size, size);
        
        const matchesPrice = !price || checkPriceMatch(property.price, price);
        
        return matchesSearch && matchesLocation && matchesType && matchesSize && matchesPrice;
    });
    
    currentPage = 1;
    loadAllProperties();
}

// Check size match
function checkSizeMatch(sizeStr, sizeCategory) {
    const sizeNum = parseInt(sizeStr.replace(/[^0-9]/g, ''));
    switch(sizeCategory) {
        case 'small': return sizeNum < 10000;
        case 'medium': return sizeNum >= 10000 && sizeNum < 50000;
        case 'large': return sizeNum >= 50000 && sizeNum < 100000;
        case 'xlarge': return sizeNum >= 100000;
        default: return true;
    }
}

// Check price match
function checkPriceMatch(priceStr, priceCategory) {
    const priceNum = parseFloat(priceStr.replace(/[^0-9.]/g, ''));
    switch(priceCategory) {
        case 'low': return priceNum < 500;
        case 'medium': return priceNum >= 500 && priceNum < 2000;
        case 'high': return priceNum >= 2000 && priceNum < 5000;
        case 'premium': return priceNum >= 5000;
        default: return true;
    }
}

// Setup sorting
function setupSorting() {
    const sortSelect = document.getElementById('sortBy');
    if (sortSelect) {
        sortSelect.addEventListener('change', applySorting);
    }
}

// Apply sorting
function applySorting() {
    const sortBy = document.getElementById('sortBy')?.value || 'newest';
    
    filteredProperties.sort((a, b) => {
        switch(sortBy) {
            case 'newest':
                return b.year - a.year;
            case 'price-low':
                return parseFloat(a.price.replace(/[^0-9.]/g, '')) - parseFloat(b.price.replace(/[^0-9.]/g, ''));
            case 'price-high':
                return parseFloat(b.price.replace(/[^0-9.]/g, '')) - parseFloat(a.price.replace(/[^0-9.]/g, ''));
            case 'size':
                return parseInt(b.size.replace(/[^0-9]/g, '')) - parseInt(a.size.replace(/[^0-9]/g, ''));
            default:
                return 0;
        }
    });
    
    currentPage = 1;
    loadAllProperties();
}

// Update results count
function updateResultsCount() {
    const countElement = document.getElementById('count');
    if (countElement) {
        countElement.textContent = filteredProperties.length;
    }
}

// Update pagination
function updatePagination() {
    const pagination = document.getElementById('pagination');
    if (!pagination) return;
    
    const totalPages = Math.ceil(filteredProperties.length / itemsPerPage);
    
    if (totalPages <= 1) {
        pagination.innerHTML = '';
        return;
    }
    
    let paginationHTML = '';
    
    // Previous button
    paginationHTML += `<button ${currentPage === 1 ? 'disabled' : ''} onclick="changePage(${currentPage - 1})">Previous</button>`;
    
    // Page numbers
    for (let i = 1; i <= totalPages; i++) {
        if (i === 1 || i === totalPages || (i >= currentPage - 1 && i <= currentPage + 1)) {
            paginationHTML += `<button class="${i === currentPage ? 'active' : ''}" onclick="changePage(${i})">${i}</button>`;
        } else if (i === currentPage - 2 || i === currentPage + 2) {
            paginationHTML += `<button disabled>...</button>`;
        }
    }
    
    // Next button
    paginationHTML += `<button ${currentPage === totalPages ? 'disabled' : ''} onclick="changePage(${currentPage + 1})">Next</button>`;
    
    pagination.innerHTML = paginationHTML;
}

// Change page
function changePage(page) {
    const totalPages = Math.ceil(filteredProperties.length / itemsPerPage);
    if (page >= 1 && page <= totalPages) {
        currentPage = page;
        loadAllProperties();
        window.scrollTo({ top: 0, behavior: 'smooth' });
    }
}

// Setup contact form
function setupContactForm() {
    const form = document.getElementById('contactForm');
    if (form) {
        form.addEventListener('submit', function(e) {
            e.preventDefault();
            
            const formData = {
                name: document.getElementById('name').value,
                email: document.getElementById('email').value,
                phone: document.getElementById('phone').value,
                message: document.getElementById('message').value
            };
            
            // In a real application, this would send data to a server
            alert('Thank you for your message! We will get back to you soon.');
            form.reset();
        });
    }
}

// Helper function
function capitalizeFirst(str) {
    return str.charAt(0).toUpperCase() + str.slice(1).replace('-', ' ');
}

