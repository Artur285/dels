# DEL Properties - Warehouse Transit Buyer Website

A modern, responsive website for warehouse property buyers specializing in transit properties.

## Features

- **Homepage** with hero section, featured properties, and company information
- **Properties Listing Page** with advanced search and filtering
- **Responsive Design** that works on all devices
- **Modern UI/UX** with smooth animations and professional styling
- **Property Search** by location, size, type, and price
- **Contact Form** for inquiries
- **Property Details** with comprehensive information

## File Structure

```
dels/
├── index.html          # Homepage
├── properties.html     # Properties listing page
├── styles.css          # All styling
├── script.js           # JavaScript functionality
└── README.md           # This file
```

## Getting Started

1. Open `index.html` in a web browser
2. Navigate through the site using the navigation menu
3. Use the search and filters on the properties page to find warehouses
4. Click on any property card to view details

## Features Overview

### Homepage
- Hero section with search functionality
- Features section highlighting key benefits
- Featured properties showcase
- About section with company statistics
- Contact form

### Properties Page
- Advanced search by keyword
- Filters for:
  - Location
  - Size (Small, Medium, Large, Extra Large)
  - Type (Distribution, Storage, Manufacturing, Cold Storage)
  - Price range
- Sort options (Newest, Price, Size)
- Pagination for easy navigation
- Property cards with key information

## Customization

### Adding Properties
Edit the `propertiesData` array in `script.js` to add or modify properties.

### Styling
Modify `styles.css` to change colors, fonts, or layout. The CSS uses CSS variables for easy theming.

### Colors
The main color scheme can be changed by modifying the CSS variables in `styles.css`:
- `--primary-color`: Main brand color
- `--secondary-color`: Accent color
- `--text-dark`: Main text color
- `--text-light`: Secondary text color

## Browser Support

- Chrome (latest)
- Firefox (latest)
- Safari (latest)
- Edge (latest)

## Notes

- This is a frontend-only implementation
- Contact form submissions are currently handled with alerts (replace with actual backend integration)
- Property images use emoji placeholders (replace with actual images)
- All property data is stored in the JavaScript file (consider using a database for production)

## GitHub Setup

To push this project to GitHub:

### Option 1: Using GitHub Web Interface (Easiest)
1. Go to https://github.com/new
2. Create a new repository named `dels` (or your preferred name)
3. **Don't** initialize with README, .gitignore, or license
4. Run these commands:
   ```bash
   git remote add origin https://github.com/YOUR_USERNAME/dels.git
   git push -u origin feature/enhanced-property-listings
   ```

### Option 2: Using GitHub CLI
```bash
# Install GitHub CLI (if not installed)
brew install gh

# Authenticate
gh auth login

# Create repository and push
gh repo create dels --public --source=. --remote=origin --push
```

### Option 3: Using Setup Script
Run the provided setup script:
```bash
./setup-github.sh
```

## License

This project is created for DEL Properties warehouse transit buyer platform.

