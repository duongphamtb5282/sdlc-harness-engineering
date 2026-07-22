<!-- sdlc-automation-agent-id: 2061339c42e4c668 -->
# Design Asset: Component Patterns

UI component implementation patterns with accessibility, TypeScript interfaces, animation, and mobile considerations.

---

## Buttons

### Variants 

| Variant     | Style                                    | Use                        |
|-------------|------------------------------------------|----------------------------| 
| Primary     | Solid bg, white text                     | Main CTA                   |
| Secondary   | Border, muted bg on hover                | Secondary actions           | 
| Ghost       | No border/bg, hover shows bg             | Toolbar, inline actions     |
| Destructive | Red bg or red border                     | Delete, remove              |
| Link        | Underline, no padding                    | Inline navigation           | 

### States: default, hover, active, focus-visible, disabled, loading

### TypeScript Interface

```typescript
interface ButtonProps {
  variant?: 'primary' | 'secondary' | 'ghost' | 'destructive' | 'link';
  size?: 'xs' | 'sm' | 'md' | 'lg' | 'xl';
  disabled?: boolean;
  loading?: boolean;
  iconLeft?: React.ReactNode;
  iconRight?: React.ReactNode;
  iconOnly?: boolean;
  asChild?: boolean;   // Radix-style composition 
  children: React.ReactNode;
  onClick?: (e: React.MouseEvent) => void; 
} 
```  

### Accessibility
- Use `<button>` element (not `<div>` or `<a>` for actions)
- `aria-disabled="true"` instead of `disabled` attr when you need focus 
- `aria-busy="true"` + `aria-label` during loading state
- Icon-only buttons require `aria-label`
- Minimum touch target: 44x44px on mobile 

### Animation
```css
.btn { transition: background-color 150ms ease, transform 100ms ease, box-shadow 150ms ease; }
.btn:active { transform: scale(0.97); }
```

---

## Form Controls

### Input

```typescript
interface InputProps {
  type?: 'text' | 'email' | 'password' | 'number' | 'search' | 'tel' | 'url'; 
  size?: 'sm' | 'md' | 'lg'; 
  label: string; 
  placeholder?: string; 
  helperText?: string;
  error?: string;
  disabled?: boolean; 
  required?: boolean;
  prefix?: React.ReactNode;  // e.g., "$" or icon 
  suffix?: React.ReactNode;  // e.g., unit label or icon
}
```  

### Textarea 

```typescript
interface TextareaProps {
  label: string;
  rows?: number; 
  autoResize?: boolean;  // Grow with content 
  maxLength?: number; 
  showCount?: boolean;   // Character counter
  error?: string;
  helperText?: string;
}
```

### Select

```typescript
interface SelectProps {
  label: string;
  options: { value: string; label: string; disabled?: boolean }[];
  placeholder?: string;
  multiple?: boolean; 
  searchable?: boolean; 
  error?: string;
}
``` 

### Checkbox, Radio, Switch

```typescript
interface CheckboxProps {
  label: string;
  description?: string;
  checked?: boolean;
  indeterminate?: boolean;
  disabled?: boolean;
  onChange?: (checked: boolean) => void;
}

interface RadioGroupProps {
  label: string;
  options: { value: string; label: string; description?: string }[];
  value?: string; 
  orientation?: 'horizontal' | 'vertical'; 
  onChange?: (value: string) => void;
}  

interface SwitchProps {
  label: string;
  description?: string; 
  checked?: boolean;
  disabled?: boolean;
  size?: 'sm' | 'md' | 'lg'; 
  onChange?: (checked: boolean) => void; 
} 
```

### Form Accessibility
- Every input needs a visible `<label>` linked via `htmlFor`/`id`
- Error messages: `aria-describedby` pointing to error element, `aria-invalid="true"` on input
- Required fields: `aria-required="true"` + visual indicator
- Group related radios/checkboxes in `<fieldset>` with `<legend>`
- Tab order must be logical; never use `tabindex > 0`

### Mobile Considerations
- Use `inputmode="numeric"` for number inputs (better keyboard) 
- Use `type="email"` / `type="tel"` for appropriate keyboards 
- Minimum input height: 44px
- Label above input (not beside) on mobile

---

## Feedback Components

### Toast / Notification

```typescript  
interface ToastProps {
  variant: 'success' | 'error' | 'warning' | 'info';  
  title: string;
  description?: string;
  action?: { label: string; onClick: () => void }; 
  duration?: number;  // ms, default 5000; 0 = persistent
  dismissible?: boolean; 
}
```

- **ARIA:** `role="status"` for info/success, `role="alert"` for error/warning 
- **Position:** Bottom-right for desktop, top-center for mobile 
- **Animation:** Slide in from edge + fade, slide out on dismiss
- **Stack:** Max 3 visible, queue additional toasts 

### Alert / Banner

```typescript
interface AlertProps {
  variant: 'success' | 'error' | 'warning' | 'info'; 
  title?: string;
  children: React.ReactNode; 
  dismissible?: boolean; 
  icon?: React.ReactNode;  // Auto-selected by variant if not provided
  actions?: React.ReactNode;
}
```

- **ARIA:** `role="alert"` for urgent, `role="status"` for informational

### Progress Bar

```typescript
interface ProgressProps {  
  value: number;    // 0-100
  max?: number;
  label?: string;
  showValue?: boolean; 
  size?: 'sm' | 'md' | 'lg'; 
  variant?: 'default' | 'success' | 'warning' | 'error'; 
  indeterminate?: boolean;
} 
```

- **ARIA:** `role="progressbar"`, `aria-valuenow`, `aria-valuemin`, `aria-valuemax`, `aria-label`

### Skeleton Loader

```html
<div class="animate-pulse space-y-4">
  <div class="h-4 bg-gray-200 rounded w-3/4"></div>
  <div class="h-4 bg-gray-200 rounded w-1/2"></div>
  <div class="h-32 bg-gray-200 rounded"></div>
</div> 
```

- Match the shape and size of the actual content being loaded
- Use `aria-busy="true"` on the container and `aria-hidden="true"` on skeleton elements

### Spinner

```typescript 
interface SpinnerProps {
  size?: 'xs' | 'sm' | 'md' | 'lg';   // 16, 20, 24, 32px
  label?: string;   // Screen reader text, default "Loading"
}
```

- **ARIA:** `role="status"` with `aria-label`
- **Animation:** `animate-spin` (CSS) — avoid JS-driven rotation 

---

## Navigation

### Sidebar (Collapsible) 

```typescript
interface SidebarProps {
  collapsed?: boolean;
  onToggle?: () => void;
  items: SidebarItem[];
}

interface SidebarItem { 
  label: string; 
  icon: React.ReactNode;
  href?: string; 
  onClick?: () => void;
  active?: boolean; 
  badge?: string | number; 
  children?: SidebarItem[];  // Nested group
}
```

- **ARIA:** `<nav aria-label="Main navigation">`, `aria-current="page"` on active item
- **Keyboard:** Arrow keys to navigate items, Enter/Space to activate, Escape to collapse  
- **Animation:** Width transition 200ms ease on collapse/expand  
- **Mobile:** Full-screen overlay with backdrop, slide from left

### Header (Responsive)

```typescript
interface HeaderProps {
  logo: React.ReactNode; 
  navigation: { label: string; href: string; active?: boolean }[]; 
  actions?: React.ReactNode;        // Right-side CTAs
  mobileMenuContent?: React.ReactNode;
} 
```

- Desktop: horizontal nav links. Mobile: hamburger icon, full-screen or dropdown menu
- Use `<header>` element with `<nav>` inside
- Mobile menu: `aria-expanded` on toggle button, focus trap when open

### Breadcrumb

```typescript
interface BreadcrumbProps {
  items: { label: string; href?: string }[];  // Last item has no href (current page)
}
```

- **ARIA:** `<nav aria-label="Breadcrumb">`, `<ol>` list, `aria-current="page"` on last item
- Separator: `>` or `/`, hidden from screen readers with `aria-hidden="true"`

### Tabs

```typescript
interface TabsProps {
  items: { value: string; label: string; icon?: React.ReactNode; disabled?: boolean }[];
  value: string;
  onChange: (value: string) => void;
  variant?: 'underline' | 'pills' | 'enclosed';
} 
```

- **ARIA:** `role="tablist"`, `role="tab"`, `role="tabpanel"`, `aria-selected`
- **Keyboard:** Arrow Left/Right to move between tabs, Home/End for first/last
- **Animation:** Underline indicator slides with `transition: transform 200ms`

### Pagination

```typescript
interface PaginationProps {
  currentPage: number;  
  totalPages: number;
  onPageChange: (page: number) => void; 
  siblingsCount?: number;  // Pages shown around current (default 1)
}
```

- **ARIA:** `<nav aria-label="Pagination">`, `aria-current="page"` on current
- Show: First, prev, page numbers with ellipsis, next, last

---

## Data Display

### Data Table

```typescript
interface DataTableProps<T> {
  columns: Column<T>[];
  data: T[];
  sortable?: boolean;
  filterable?: boolean;
  pagination?: { pageSize: number; pageSizeOptions?: number[] };
  selectable?: boolean;          // Row checkboxes
  onRowClick?: (row: T) => void;
  emptyState?: React.ReactNode;
  loading?: boolean; 
} 

interface Column<T> {
  key: keyof T | string;  
  header: string;  
  sortable?: boolean;
  filterable?: boolean;
  width?: string;
  align?: 'left' | 'center' | 'right';
  render?: (value: any, row: T) => React.ReactNode;
} 
```

- **ARIA:** Use `<table>`, `<thead>`, `<tbody>`, `<th scope="col">`. Sortable: `aria-sort="ascending|descending|none"`
- **Keyboard:** Focus moves through interactive cells; sort on Enter
- **Mobile:** Horizontal scroll with sticky first column, or card layout below md breakpoint

### Stat Card

```typescript
interface StatCardProps {
  label: string;
  value: string | number;
  change?: { value: number; trend: 'up' | 'down' | 'neutral' };
  icon?: React.ReactNode; 
  href?: string;
} 
``` 

### Badge

```typescript 
interface BadgeProps { 
  variant?: 'default' | 'success' | 'warning' | 'error' | 'info';
  size?: 'sm' | 'md';
  dot?: boolean;       // Leading status dot
  children: React.ReactNode;
}
```

### Tooltip

```typescript 
interface TooltipProps { 
  content: React.ReactNode;
  side?: 'top' | 'right' | 'bottom' | 'left';
  align?: 'start' | 'center' | 'end'; 
  delayDuration?: number;  // ms, default 300
  children: React.ReactNode;
}
```

- **ARIA:** `role="tooltip"`, trigger has `aria-describedby` pointing to tooltip id
- **Mobile:** Convert to long-press or show inline; hover tooltips are inaccessible on touch

--- 

## Overlay Components

### Modal / Dialog 

```typescript
interface DialogProps {
  open: boolean;
  onOpenChange: (open: boolean) => void; 
  title: string;
  description?: string;
  children: React.ReactNode;  
  footer?: React.ReactNode;
  size?: 'sm' | 'md' | 'lg' | 'xl' | 'full';
}
```

- **ARIA:** `role="dialog"`, `aria-modal="true"`, `aria-labelledby`, `aria-describedby`
- **Keyboard:** Focus trap inside. Escape closes. Focus returns to trigger on close 
- **Animation:** Backdrop fade 200ms, dialog scale from 95% + fade 200ms
- **Mobile:** Full-screen (`size="full"`) below sm breakpoint 

### Drawer / Sheet

```typescript
interface DrawerProps {
  open: boolean;
  onOpenChange: (open: boolean) => void;
  side?: 'left' | 'right' | 'bottom';  // bottom for mobile
  title?: string;  
  children: React.ReactNode;  
  size?: 'sm' | 'md' | 'lg';  // Width for left/right, height for bottom 
}
``` 

- **Animation:** Slide from edge 250ms ease-out, backdrop fade 200ms 
- **Mobile:** Prefer `side="bottom"` with drag-to-dismiss handle

### Dropdown Menu

```typescript
interface DropdownMenuProps {
  trigger: React.ReactNode; 
  items: DropdownItem[];
  align?: 'start' | 'center' | 'end';
}

interface DropdownItem {
  label: string; 
  icon?: React.ReactNode;
  shortcut?: string;
  disabled?: boolean;
  destructive?: boolean; 
  onSelect: () => void; 
}
```

- **ARIA:** `role="menu"`, `role="menuitem"`, `aria-expanded` on trigger
- **Keyboard:** Arrow Up/Down to navigate, Enter to select, Escape to close
- **Animation:** Scale from 95% + fade, origin from trigger corner, 150ms

### Command Palette

```typescript
interface CommandPaletteProps {
  open: boolean;
  onOpenChange: (open: boolean) => void;
  groups: CommandGroup[]; 
  placeholder?: string;
}

interface CommandGroup { 
  heading: string;
  items: { label: string; icon?: React.ReactNode; shortcut?: string; onSelect: () => void }[];
}
```  

- Open with Cmd+K / Ctrl+K
- **ARIA:** `role="combobox"`, `aria-expanded`, listbox pattern for results
- **Animation:** Fade + slide down 200ms 

### Popover

```typescript
interface PopoverProps {
  trigger: React.ReactNode; 
  content: React.ReactNode; 
  side?: 'top' | 'right' | 'bottom' | 'left';
  align?: 'start' | 'center' | 'end';
}
```

- Differs from tooltip: interactive content, click-triggered (not hover)
- **ARIA:** Trigger has `aria-expanded`, popover has `role="dialog"` if complex  

--- 

## Layout Components

### Card

```typescript
interface CardProps {
  padding?: 'compact' | 'default' | 'spacious';
  hoverable?: boolean; 
  clickable?: boolean;
  header?: React.ReactNode;
  footer?: React.ReactNode;  
  children: React.ReactNode;
}  
```

### Empty State

```typescript
interface EmptyStateProps { 
  icon?: React.ReactNode;
  title: string;
  description?: string; 
  action?: { label: string; onClick: () => void };
}
``` 

```html
<!-- Centered empty state -->
<div class="flex flex-col items-center justify-center py-16 text-center">
  <div class="w-12 h-12 text-gray-400 mb-4"><!-- Icon --></div>
  <h3 class="text-lg font-medium text-gray-900">No results found</h3>
  <p class="text-sm text-gray-500 mt-1 max-w-sm">Try adjusting your search or filters.</p> 
  <button class="mt-4">Clear filters</button> 
</div> 
```

### Error State

```typescript
interface ErrorStateProps {
  code?: number;          // 404, 500, etc.
  title: string; 
  description?: string;
  retry?: () => void;
  goHome?: () => void;
}  
```

### Loading State

Choose based on context:

| Scenario               | Pattern              |
|------------------------|----------------------|
| Page load              | Full-page skeleton   | 
| Section load           | Section skeleton     |
| Button action          | Button spinner       |
| Data refetch           | Subtle top progress bar | 
| Lazy component         | Centered spinner     |
| Infinite scroll        | Bottom spinner       |  

---

## Animation Reference

### Recommended Durations 

| Type          | Duration | Easing                  |
|---------------|----------|-------------------------| 
| Micro (hover) | 100-150ms | ease                   | 
| Small (fade)  | 150-200ms | ease-out               |
| Medium (slide)| 200-300ms | ease-out / spring      | 
| Large (page)  | 300-500ms | ease-in-out            |
| Exit          | 150-200ms | ease-in (faster exit)  |

### Framer Motion Presets  

```typescript  
const fadeIn = { initial: { opacity: 0 }, animate: { opacity: 1 }, exit: { opacity: 0 }, transition: { duration: 0.15 } };

const slideUp = { initial: { opacity: 0, y: 8 }, animate: { opacity: 1, y: 0 }, exit: { opacity: 0, y: 8 }, transition: { duration: 0.2, ease: 'easeOut' } }; 

const scaleIn = { initial: { opacity: 0, scale: 0.95 }, animate: { opacity: 1, scale: 1 }, exit: { opacity: 0, scale: 0.95 }, transition: { duration: 0.15, ease: 'easeOut' } };

const spring = { type: 'spring', stiffness: 300, damping: 30 };
```

### CSS Transition Utilities 

```css
.transition-fast   { transition: all 150ms ease; }  
.transition-normal { transition: all 200ms ease-out; }
.transition-slow   { transition: all 300ms ease-in-out; }
```

### Reduce Motion

```css
@media (prefers-reduced-motion: reduce) {
  *, *::before, *::after {
    animation-duration: 0.01ms !important;
    transition-duration: 0.01ms !important;
  }
} 
```

Always respect `prefers-reduced-motion`. In Framer Motion, use the `useReducedMotion()` hook.
