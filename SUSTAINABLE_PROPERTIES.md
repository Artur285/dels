# Sustainable Usage of Linked Properties

This document outlines the improvements made to ensure sustainable usage of CSS custom properties (CSS variables) and JavaScript property data management throughout the codebase.

## Overview

The codebase has been refactored to use a comprehensive design system based on CSS custom properties and a centralized property data management system. This ensures:

- **Maintainability**: Change values in one place, update everywhere
- **Consistency**: Unified design tokens across all components
- **Scalability**: Easy to extend and modify
- **Performance**: Reduced code duplication

## CSS Custom Properties System

### Design Tokens Structure

All design tokens are now defined in `:root` in `styles.css`:

#### Color System
- **Primary Palette**: `--primary-color`, `--primary-dark`, `--primary-light`, etc.
- **Secondary Palette**: `--secondary-color`, `--secondary-dark`, etc.
- **Status Colors**: `--status-available`, `--status-pending`, `--status-error`, etc.
- **Neutral Palette**: `--text-dark`, `--text-light`, `--bg-light`, `--bg-white`, etc.

#### Gradient System
- `--gradient-primary`: Primary color gradient
- `--gradient-secondary`: Secondary color gradient
- `--gradient-hero`: Hero section gradient
- `--gradient-text-primary`: Text gradient with primary colors
- `--gradient-card`: Card background gradient

#### Shadow System
- Base shadows: `--shadow-sm`, `--shadow-md`, `--shadow-lg`, `--shadow-xl`, `--shadow-2xl`
- Colored shadows: `--shadow-primary`, `--shadow-secondary`, `--shadow-pending`

#### Spacing System (8px base unit)
- `--spacing-xs` through `--spacing-5xl`
- Consistent spacing scale throughout

#### Typography System
- Font sizes: `--font-size-xs` through `--font-size-6xl`
- Font weights: `--font-weight-light` through `--font-weight-black`
- Line heights: `--line-height-tight` through `--line-height-loose`

#### Other Systems
- Border radius: `--radius-sm` through `--radius-full`
- Transitions: `--transition-fast` through `--transition-bounce`
- Opacity: `--opacity-disabled`, `--opacity-hover`, `--opacity-overlay`
- Z-index: `--z-base` through `--z-navbar`
- Layout: `--container-max-width`, `--container-padding`, `--grid-gap`

### Usage Examples

**Before:**
```css
.property-card {
    background: white;
    border-radius: 20px;
    box-shadow: 0 4px 16px rgba(0, 0, 0, 0.08);
    transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
}
```

**After:**
```css
.property-card {
    background: var(--bg-white);
    border-radius: var(--radius-2xl);
    box-shadow: var(--shadow-md);
    transition: all var(--transition-cubic);
}
```

## JavaScript Property Data Management

### PropertyStore Object

A centralized `PropertyStore` object provides sustainable access to property data:

```javascript
PropertyStore = {
    data: [...], // All properties
    
    // Methods
    getAll(),              // Get all properties
    getById(id),          // Get property by ID
    getFeatured(count),   // Get featured properties
    filter(criteria),     // Filter by criteria
    search(keyword),      // Search by keyword
    getLocations(),       // Get unique locations
    getTypes(),           // Get unique types
    getByStatus(status)   // Get properties by status
}
```

### Benefits

1. **Single Source of Truth**: All property data access goes through PropertyStore
2. **Reusable Methods**: Common operations are abstracted
3. **Easy to Extend**: Add new methods without changing existing code
4. **Backward Compatible**: Maintains `propertiesData` reference for existing code

### Usage Examples

**Before:**
```javascript
const featured = propertiesData.slice(0, 6);
const property = propertiesData.find(p => p.id === id);
```

**After:**
```javascript
const featured = PropertyStore.getFeatured(6);
const property = PropertyStore.getById(id);
```

## Files Updated

1. **styles.css**: Comprehensive CSS custom properties system
2. **script.js**: PropertyStore object for data management
3. **hold-scroll.html**: Uses CSS variables for all styling

## Best Practices

### When Adding New Styles

1. **Check for existing variables first**: Don't create new hard-coded values
2. **Use semantic names**: `--primary-color` not `--blue-500`
3. **Follow the system**: Use spacing, typography, and color systems
4. **Document new variables**: Add comments explaining purpose

### When Working with Property Data

1. **Use PropertyStore methods**: Don't access `propertiesData` directly
2. **Extend PropertyStore**: Add new methods for new use cases
3. **Maintain backward compatibility**: Keep `propertiesData` reference

## Future Enhancements

- [ ] Add theme switching (light/dark mode)
- [ ] Create component-level CSS variable scopes
- [ ] Add property data validation
- [ ] Implement property caching for performance
- [ ] Add TypeScript definitions for PropertyStore

## Migration Guide

To migrate existing code:

1. Replace hard-coded colors with CSS variables
2. Replace hard-coded spacing with spacing variables
3. Replace direct `propertiesData` access with `PropertyStore` methods
4. Test thoroughly after migration

## Benefits Summary

✅ **Maintainability**: Change design tokens in one place
✅ **Consistency**: Unified design system
✅ **Scalability**: Easy to extend
✅ **Performance**: Reduced duplication
✅ **Developer Experience**: Clear, semantic naming
✅ **Future-proof**: Easy to add themes, dark mode, etc.

