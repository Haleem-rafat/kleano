# Kleano Admin Dashboard - UI Design System

## 🎨 Design Philosophy

This design system follows a **modern, professional dashboard aesthetic** with clean layouts,
consistent spacing, and intuitive user interactions. The design prioritizes information hierarchy,
visual clarity, and responsive behavior across all screen sizes.

## 🏗️ Core Design Principles

### 1. **Card-Based Layout**

- All content sections are wrapped in cards with subtle shadows
- Cards have rounded corners (`rounded-xl`) for modern appearance
- Consistent border styling (`border-slate-200`)
- White background with subtle shadow (`shadow-sm`)

### 2. **Gradient Headers**

- Each section has a gradient header with white text
- Consistent header height and padding
- Icon + title + description structure
- Color coding for different content types:
  - **Blue** (`from-blue-600 to-blue-700`): User/Profile information
  - **Purple** (`from-purple-600 to-purple-700`): Vehicle/Asset information
  - **Green** (`from-green-600 to-green-700`): Orders/Transactions
  - **Emerald** (`from-emerald-600 to-emerald-700`): Statistics/Analytics
  - **Orange** (`from-orange-600 to-orange-700`): Location/Geographic data
  - **Indigo** (`from-indigo-600 to-indigo-700`): Biker/Service provider info

### 3. **Typography Hierarchy**

- **Headers**: `text-2xl font-semibold` for main page titles
- **Section Titles**: `text-lg font-semibold` for card headers
- **Labels**: `text-xs font-medium uppercase tracking-wide text-slate-500`
- **Values**: `text-lg font-semibold text-slate-900` for important data
- **Descriptions**: `text-sm text-slate-500` for secondary information

### 4. **Spacing & Layout**

- **Page Container**: `max-w-7xl mx-auto` for main content
- **Card Padding**: `p-6` for card content
- **Section Spacing**: `gap-6` between cards
- **Grid Layouts**: Responsive grids with `grid-cols-1 sm:grid-cols-2 lg:grid-cols-3`
- **Internal Spacing**: `space-y-4` for vertical spacing within sections

### 5. **Color Palette**

- **Primary Background**: `bg-slate-50` for page background
- **Card Background**: `bg-white`
- **Text Colors**:
  - Primary: `text-slate-900`
  - Secondary: `text-slate-600`
  - Muted: `text-slate-500`
  - Success: `text-green-600`
  - Error: `text-red-600`
  - Warning: `text-orange-600`

### 6. **Interactive Elements**

- **Buttons**: Consistent styling with hover states
- **Clickable Cards**: Hover effects with border color changes and shadow
- **Navigation**: Clear visual indicators for clickable elements
- **Transitions**: `transition-all duration-200` for smooth interactions

## 📱 Responsive Design

### Breakpoints

- **Mobile**: `grid-cols-1` (default)
- **Tablet**: `sm:grid-cols-2` (640px+)
- **Desktop**: `lg:grid-cols-3` (1024px+)
- **Large Desktop**: `xl:grid-cols-3` (1280px+)

### Layout Patterns

- **Main Layout**: `grid grid-cols-1 xl:grid-cols-3 gap-6`
- **Stats Grid**: `grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3`
- **Form Layouts**: `grid grid-cols-1 sm:grid-cols-2 gap-4`

## 🎯 Component Patterns

### 1. **Section Headers**

```tsx
<div className="from-[color]-600 to-[color]-700 bg-gradient-to-r px-6 py-4">
  <div className="flex items-center space-x-3">
    <div className="flex h-12 w-12 items-center justify-center rounded-full bg-white/20">
      <Icon className="h-6 w-6 text-white" />
    </div>
    <div>
      <h2 className="text-lg font-semibold text-white">{title}</h2>
      <p className="text-[color]-100 text-sm">{description}</p>
    </div>
  </div>
</div>
```

### 2. **Data Display Cards**

```tsx
<div className="rounded-lg bg-slate-50 p-4">
  <h4 className="mb-2 text-sm font-semibold text-slate-700">{label}</h4>
  <p className="text-lg font-bold text-slate-900">{value}</p>
</div>
```

### 3. **Statistics Cards**

```tsx
<div className="text-center">
  <div className="bg-[color]-100 mx-auto mb-3 flex h-12 w-12 items-center justify-center rounded-full">
    <Icon className="text-[color]-600 h-6 w-6" />
  </div>
  <p className="text-2xl font-bold text-slate-900">{value}</p>
  <p className="text-sm text-slate-500">{label}</p>
</div>
```

### 4. **Interactive Cards**

```tsx
<div className="hover:border-[color]-300 hover:shadow-[color]-100 cursor-pointer overflow-hidden rounded-lg border border-slate-200 bg-white p-4 shadow-sm transition-all duration-200 hover:shadow-md">
  {/* Card content */}
</div>
```

## 🔧 Implementation Guidelines

### 1. **Consistent Imports**

```tsx
import { Card, CardContent, CardHeader, CardTitle } from '@shadecn/components/ui/card';
import { Badge } from '@shadecn/components/ui/badge';
import { Button } from '@shadecn/components/ui/button';
import { ImageModal } from '@UI/Index';
```

### 2. **Icon Usage**

- Use `react-icons/io5` for consistency
- Standard icon sizes: `h-4 w-4`, `h-5 w-5`, `h-6 w-6`
- Color coding: `text-slate-400` for secondary icons, `text-[color]-600` for primary

### 3. **Empty States**

```tsx
<div className="py-12 text-center">
  <div className="mx-auto mb-4 flex h-16 w-16 items-center justify-center rounded-full bg-slate-100">
    <Icon className="h-8 w-8 text-slate-400" />
  </div>
  <h3 className="mb-1 text-lg font-medium text-slate-900">{title}</h3>
  <p className="text-slate-500">{description}</p>
</div>
```

### 4. **Loading States**

- Use `ThreeDotsLoader` component
- Show loading state before data is available
- Maintain layout structure during loading

## 📋 Page Structure Template

```tsx
export default function PageName() {
  return (
    <div className="min-h-screen bg-slate-50">
      {/* Professional Header */}
      <div className="border-b border-slate-200 bg-white shadow-sm">
        <div className="px-6 py-4">
          <div className="flex items-center justify-between">
            <div className="flex items-center space-x-4">
              <button type="button" onClick={() => navigate(-1)}>
                <IoArrowBackCircleOutline className="h-5 w-5 text-slate-600" />
              </button>
              <div>
                <h1 className="text-2xl font-semibold text-slate-900">{title}</h1>
                <p className="mt-1 text-sm text-slate-500">{subtitle}</p>
              </div>
            </div>
            {/* Action buttons */}
          </div>
        </div>
      </div>

      {/* Main Content */}
      <div className="p-6">
        <div className="mx-auto max-w-[95%]">
          <div className="grid grid-cols-1 gap-6 xl:grid-cols-3">{/* Content sections */}</div>
        </div>
      </div>
    </div>
  );
}
```

## 🎨 Visual Consistency Rules

1. **Always use the gradient header pattern** for section identification
2. **Maintain consistent spacing** using the defined spacing scale
3. **Use color coding** to group related information
4. **Implement hover states** for interactive elements
5. **Ensure responsive behavior** across all breakpoints
6. **Follow the typography hierarchy** for text elements
7. **Use consistent border radius** (`rounded-xl` for cards, `rounded-lg` for smaller elements)
8. **Apply consistent shadows** (`shadow-sm` for cards, `shadow-md` for hover states)

## 🚀 Future Enhancements

When implementing new UI components or pages, always:

1. Reference this design system
2. Follow the established patterns
3. Maintain color consistency
4. Ensure responsive design
5. Test hover states and interactions
6. Validate accessibility standards

This design system ensures a cohesive, professional, and user-friendly experience across the entire
Kleano Admin Dashboard.
