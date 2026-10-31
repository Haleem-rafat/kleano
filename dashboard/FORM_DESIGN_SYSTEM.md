# Kleano Admin Dashboard - Form Design System

## 🎨 Form Design Philosophy

This form design system extends the main UI design system with specific patterns for forms, ensuring
consistency, accessibility, and user-friendly interactions. Forms follow a **clean, organized, and
intuitive** approach with clear visual hierarchy and responsive behavior.

## 🏗️ Core Form Design Principles

### 1. **Form Container Structure**

- **Main Container**: Card-based layout with consistent styling
- **Header Section**: Gradient header with form title and description
- **Content Area**: Well-organized sections with proper spacing
- **Action Area**: Clear submit/cancel button placement

### 2. **Form Layout Patterns**

#### **Single Column Layout** (Default)

```tsx
<div className="space-y-6">{/* Form sections */}</div>
```

#### **Two Column Layout** (Related fields)

```tsx
<div className="grid grid-cols-1 gap-4 sm:grid-cols-2">{/* Form fields */}</div>
```

#### **Three Column Layout** (Social links, tags, etc.)

```tsx
<div className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-3">{/* Form fields */}</div>
```

### 3. **Form Section Organization**

#### **Section Headers**

```tsx
<div className="mb-6 border-b border-slate-200 pb-4">
  <h3 className="text-lg font-semibold text-slate-900">{sectionTitle}</h3>
  <p className="mt-1 text-sm text-slate-500">{sectionDescription}</p>
</div>
```

#### **Field Groups**

```tsx
<div className="space-y-4">
  <div className="grid grid-cols-1 gap-4 sm:grid-cols-2">{/* Related fields */}</div>
</div>
```

### 4. **Dynamic Field Arrays**

#### **Array Field Container**

```tsx
<div className="space-y-4">
  <div className="flex items-center justify-between">
    <h4 className="text-sm font-medium text-slate-700">{fieldLabel}</h4>
    <Button
      type="button"
      variant="outline"
      size="sm"
      onClick={handleAdd}
      className="flex items-center gap-2">
      <IoAdd className="h-4 w-4" />
      Add {fieldName}
    </Button>
  </div>

  <div className="space-y-3">{/* Dynamic fields */}</div>
</div>
```

#### **Array Field Item**

```tsx
<div className="flex items-center gap-3 rounded-lg border border-slate-200 bg-slate-50 p-4">
  <div className="flex-1">{/* Input field */}</div>
  <Button type="button" variant="destructive" size="sm" onClick={handleRemove} className="shrink-0">
    <IoTrash className="h-4 w-4" />
  </Button>
</div>
```

### 5. **Form Actions**

#### **Action Buttons Container**

```tsx
<div className="flex items-center justify-between border-t border-slate-200 pt-6">
  <div className="flex items-center gap-3">{/* Secondary actions */}</div>
  <div className="flex items-center gap-3">{/* Primary actions */}</div>
</div>
```

#### **Button Styling**

- **Primary Submit**: `bg-blue-600 hover:bg-blue-700 text-white`
- **Secondary**: `bg-slate-100 hover:bg-slate-200 text-slate-700`
- **Destructive**: `bg-red-600 hover:bg-red-700 text-white`
- **Outline**: `border border-slate-300 hover:bg-slate-50 text-slate-700`

### 6. **Form Validation & Error States**

#### **Error Display**

```tsx
{
  error && (
    <p className="mt-1 flex items-center gap-1 text-sm text-red-600">
      <IoWarning className="h-4 w-4" />
      {error.message}
    </p>
  );
}
```

#### **Success States**

```tsx
<div className="flex items-center gap-2 text-green-600">
  <IoCheckmarkCircle className="h-4 w-4" />
  <span className="text-sm">Field is valid</span>
</div>
```

### 7. **Loading States**

#### **Form Loading**

```tsx
{
  isLoading ? (
    <div className="flex items-center justify-center py-12">
      <ThreeDotsLoader />
    </div>
  ) : (
    {
      /* Form content */
    }
  );
}
```

#### **Field Loading**

```tsx
<div className="relative">
  <MainInput {...props} disabled={isLoading} />
  {isLoading && (
    <div className="absolute right-3 top-1/2 -translate-y-1/2">
      <div className="h-4 w-4 animate-spin rounded-full border-2 border-blue-600 border-t-transparent" />
    </div>
  )}
</div>
```

## 📱 Responsive Form Design

### Breakpoints

- **Mobile**: Single column layout, stacked buttons
- **Tablet**: Two column layout for related fields
- **Desktop**: Three column layout for social links, optimal spacing

### Mobile Optimizations

- Touch-friendly button sizes (min 44px height)
- Proper input spacing for mobile keyboards
- Swipe-friendly dynamic field removal
- Clear visual feedback for interactions

## 🎯 Form Component Patterns

### 1. **Complete Form Template**

```tsx
export default function FormName() {
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
                <h1 className="text-2xl font-semibold text-slate-900">{formTitle}</h1>
                <p className="mt-1 text-sm text-slate-500">{formDescription}</p>
              </div>
            </div>
            {/* Action buttons */}
          </div>
        </div>
      </div>

      {/* Form Content */}
      <div className="p-6">
        <div className="mx-auto max-w-4xl">
          <Card className="overflow-hidden">{/* Form sections */}</Card>
        </div>
      </div>
    </div>
  );
}
```

### 2. **Form Section Template**

```tsx
<div className="p-6">
  <div className="space-y-6">
    {/* Section Header */}
    <div className="border-b border-slate-200 pb-4">
      <h3 className="text-lg font-semibold text-slate-900">{sectionTitle}</h3>
      <p className="mt-1 text-sm text-slate-500">{sectionDescription}</p>
    </div>

    {/* Form Fields */}
    <div className="space-y-4">{/* Field groups */}</div>
  </div>
</div>
```

### 3. **Social Links Section**

```tsx
<div className="space-y-4">
  <div className="border-b border-slate-200 pb-4">
    <h3 className="text-lg font-semibold text-slate-900">Social Media Links</h3>
    <p className="mt-1 text-sm text-slate-500">Connect your social media profiles</p>
  </div>

  <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-3">
    {socialLinks.map((link) => (
      <div key={link.name} className="space-y-2">
        <label className="flex items-center gap-2 text-sm font-medium text-slate-700">
          <Icon className="h-4 w-4 text-slate-500" />
          {link.label}
        </label>
        <MainInput placeholder={`Enter ${link.label} URL`} type="url" field={field} />
      </div>
    ))}
  </div>
</div>
```

## 🔧 Implementation Guidelines

### 1. **Consistent Imports**

```tsx
import { Card, CardContent, CardHeader, CardTitle } from '@shadecn/components/ui/card';
import { Button } from '@shadecn/components/ui/button';
import { MainInput } from '@UI/Index';
import { IoAdd, IoTrash, IoWarning, IoCheckmarkCircle } from 'react-icons/io5';
```

### 2. **Form Validation**

- Use Yup for schema validation
- Display errors inline with fields
- Show success states for completed sections
- Prevent submission with validation errors

### 3. **Accessibility**

- Proper label associations
- ARIA attributes for dynamic content
- Keyboard navigation support
- Screen reader friendly error messages

### 4. **Performance**

- Debounced input validation
- Optimistic updates where appropriate
- Lazy loading for large forms
- Efficient re-renders

## 🎨 Visual Consistency Rules

1. **Use consistent spacing** with the defined scale
2. **Maintain proper visual hierarchy** with section headers
3. **Apply consistent button styling** across all actions
4. **Use appropriate color coding** for different field types
5. **Ensure responsive behavior** across all breakpoints
6. **Implement proper loading states** for better UX
7. **Follow accessibility guidelines** for form elements
8. **Use consistent error/success messaging** patterns

## 🚀 Form-Specific Enhancements

When implementing forms, always:

1. **Group related fields** logically
2. **Use appropriate input types** for better mobile experience
3. **Implement proper validation** with clear error messages
4. **Add loading states** for better user feedback
5. **Ensure keyboard navigation** works properly
6. **Test on mobile devices** for touch interactions
7. **Validate accessibility** with screen readers
8. **Follow the established patterns** for consistency

This form design system ensures a cohesive, professional, and user-friendly form experience across
the entire Kleano Admin Dashboard.
