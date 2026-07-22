<!-- sdlc-automation-agent-id: 2061339c42e4c668 -->
# Design Asset: Spacing & Layout Systems

Spacing scales, page layout patterns, responsive breakpoints, and grid systems.

---

## 4px Base Grid — Spacing Scale

All spacing derives from a 4px base unit. This matches the Tailwind default scale.

| Token  | Tailwind | px   | rem     | Common Use                        | 
|--------|----------|------|---------|-----------------------------------|
| 0      | `0`      | 0    | 0       | Reset                             |
| 0.5    | `0.5`    | 2    | 0.125   | Hairline gap                      |
| 1      | `1`      | 4    | 0.25    | Tight inline gap                  |
| 1.5    | `1.5`    | 6    | 0.375   | Icon-to-text gap                  | 
| 2      | `2`      | 8    | 0.5     | Button padding-y, badge padding   |
| 2.5    | `2.5`    | 10   | 0.625   | Small element spacing             |
| 3      | `3`      | 12   | 0.75    | Input padding-y, compact gap      |
| 3.5    | `3.5`    | 14   | 0.875   | —                                 |
| 4      | `4`      | 16   | 1       | Card padding (compact), form gap  |
| 5      | `5`      | 20   | 1.25    | Card padding (default)            |
| 6      | `6`      | 24   | 1.5     | Card padding (spacious), section  |
| 7      | `7`      | 28   | 1.75    | —                                 |
| 8      | `8`      | 32   | 2       | Section gap (small)               | 
| 9      | `9`      | 36   | 2.25    | —                                 |
| 10     | `10`     | 40   | 2.5     | Section gap (medium)              | 
| 11     | `11`     | 44   | 2.75    | —                                 | 
| 12     | `12`     | 48   | 3       | Section gap (large)               |
| 14     | `14`     | 56   | 3.5     | Page section spacing              |
| 16     | `16`     | 64   | 4       | Major section gap, header height  | 
| 20     | `20`     | 80   | 5       | Page-level spacing                |
| 24     | `24`     | 96   | 6       | Hero padding                      | 
| 28     | `28`     | 112  | 7       | Large hero spacing                |
| 32     | `32`     | 128  | 8       | Maximum section spacing           |

---  

## Component Spacing Patterns

### Cards

```html 
<!-- Compact card (data tables, dense lists) -->
<div class="p-3 sm:p-4 rounded-lg border">...</div>

<!-- Default card -->
<div class="p-4 sm:p-5 lg:p-6 rounded-xl border shadow-sm">...</div>

<!-- Feature/marketing card -->
<div class="p-6 sm:p-8 rounded-2xl border shadow-md">...</div>
```  

| Card Type   | Padding       | Border Radius | Gap Between Cards |
|-------------|---------------|---------------|-------------------|
| Compact     | p-3 to p-4    | rounded-lg    | gap-3             |
| Default     | p-4 to p-6    | rounded-xl    | gap-4 to gap-6    | 
| Feature     | p-6 to p-8    | rounded-2xl   | gap-6 to gap-8    |

### Forms

```html 
<form class="space-y-4">                    <!-- Field spacing -->
  <div class="space-y-1.5">                 <!-- Label-to-input -->
    <label class="text-sm font-medium">...</label> 
    <input class="px-3 py-2 rounded-md border" /> 
    <p class="text-sm text-gray-500">Helper text</p>
  </div>
</form>
```  

| Element             | Spacing             | 
|---------------------|---------------------| 
| Between fields      | space-y-4           |
| Label to input      | space-y-1.5         |
| Input to helper     | mt-1                |
| Form sections       | space-y-6 to space-y-8 |
| Submit button       | mt-6 to mt-8        |

### Buttons

| Size    | Padding        | Height  | Font Size | Icon Size |
|---------|----------------|---------|-----------|-----------|
| xs      | px-2 py-1      | h-7     | text-xs   | 14px      |
| sm      | px-3 py-1.5    | h-8     | text-sm   | 16px      |
| md      | px-4 py-2      | h-9     | text-sm   | 18px      |
| lg      | px-5 py-2.5    | h-10    | text-base | 20px      |  
| xl      | px-6 py-3      | h-12    | text-base | 22px      | 

---

## Page Layout Patterns

### Core Dimensions 

| Element           | Value             | CSS                       |
|-------------------|-------------------|---------------------------|
| Sidebar width     | 240px (collapsed: 64px) | `w-60` / `w-16`    |
| Sidebar wide      | 280px             | `w-70`                    |
| Header height     | 64px              | `h-16`                    |
| Content max-width | 1280px            | `max-w-screen-xl`         |
| Narrow content    | 768px             | `max-w-3xl`               |
| Reading width     | 65ch              | `max-w-prose`             |
| Footer min-height | 64px              | `min-h-16`                |

### Standard Container

```html
<!-- Responsive page container -->
<div class="max-w-screen-xl mx-auto px-4 sm:px-6 lg:px-8">
  <!-- Content --> 
</div> 
```

### Dashboard Layout (Sidebar + Main) 

```html
<div class="flex h-screen">
  <!-- Sidebar: fixed width, full height -->  
  <aside class="w-60 shrink-0 border-r bg-gray-50 overflow-y-auto hidden lg:block">
    <!-- Nav items -->
  </aside> 

  <!-- Main content area --> 
  <div class="flex-1 flex flex-col min-w-0"> 
    <!-- Header -->
    <header class="h-16 shrink-0 border-b flex items-center px-4 sm:px-6">
      <!-- Mobile menu button, breadcrumb, actions -->
    </header>

    <!-- Scrollable content -->
    <main class="flex-1 overflow-y-auto p-4 sm:p-6 lg:p-8">
      <div class="max-w-screen-xl mx-auto">
        <!-- Page content -->
      </div>  
    </main> 
  </div>
</div>
```

### Stacked Layout (Header + Content + Footer)

```html
<div class="min-h-screen flex flex-col"> 
  <header class="h-16 shrink-0 border-b">...</header>
  <main class="flex-1"> 
    <div class="max-w-screen-xl mx-auto px-4 sm:px-6 lg:px-8 py-8 sm:py-12">
      <!-- Content -->
    </div>  
  </main>
  <footer class="border-t py-8">...</footer>  
</div>
```

--- 

## Responsive Breakpoints 

| Breakpoint | Width  | Prefix | Typical Layout Change                        |
|------------|--------|--------|----------------------------------------------| 
| Default    | 0+     | —      | Single column, stacked layout, mobile nav    |
| sm         | 640px  | `sm:`  | 2-column grid for cards, larger padding      |
| md         | 768px  | `md:`  | Side-by-side form fields, tablet nav         |
| lg         | 1024px | `lg:`  | Sidebar visible, 3-column grids, desktop nav |  
| xl         | 1280px | `xl:`  | 4-column grids, wider content area           |
| 2xl        | 1536px | `2xl:` | Max-width container, extra whitespace         |  

### Breakpoint Behavior Cheat Sheet 

```
Mobile (< 640px):
  - Stack everything vertically
  - Full-width cards, inputs, buttons
  - Hamburger menu / bottom nav
  - px-4 container padding

sm (640px+):
  - 2-column card grids 
  - Side-by-side small elements
  - px-6 container padding

md (768px+):
  - 2-column form layouts  
  - Tablet navigation (top bar expanded) 
  - Modals wider (max-w-lg) 

lg (1024px+):
  - Sidebar navigation visible 
  - 3-column grids
  - px-8 container padding
  - Side panels / split views

xl (1280px+):
  - 4-column grids
  - Content max-width reached
  - Generous whitespace

2xl (1536px+):
  - Ultra-wide optimizations  
  - Three-panel layouts
```

---

## Grid Patterns

### Responsive Card Grid (1 -> 2 -> 3 -> 4 columns) 

```html
<div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4 sm:gap-6">
  <div class="rounded-xl border p-4">Card</div>
  <!-- More cards -->
</div>
```

### Dashboard Stats Row 

```html
<div class="grid grid-cols-2 lg:grid-cols-4 gap-4">
  <div class="rounded-lg border p-4"> 
    <p class="text-sm text-gray-500">Metric</p>
    <p class="text-2xl font-semibold">1,234</p>
  </div>
  <!-- 3 more stats -->
</div>
```

### Content + Sidebar (Sticky)  

```html  
<div class="lg:grid lg:grid-cols-[1fr_280px] lg:gap-8">
  <main><!-- Primary content --></main> 
  <aside class="hidden lg:block">
    <div class="sticky top-24 space-y-6"> 
      <!-- Sidebar widgets --> 
    </div>
  </aside>
</div>
```

### Two-Column Form 

```html 
<div class="grid grid-cols-1 md:grid-cols-2 gap-x-6 gap-y-4">
  <div class="space-y-1.5">
    <label>First Name</label>
    <input class="w-full" />
  </div> 
  <div class="space-y-1.5"> 
    <label>Last Name</label>
    <input class="w-full" />
  </div> 
  <!-- Full-width field spanning both columns -->
  <div class="md:col-span-2 space-y-1.5">
    <label>Address</label>
    <input class="w-full" />
  </div>
</div>
```

### Masonry-like with CSS Columns

```html
<!-- Simple masonry for variable-height cards -->
<div class="columns-1 sm:columns-2 lg:columns-3 gap-4 space-y-4">
  <div class="break-inside-avoid rounded-xl border p-4">
    <!-- Variable height content -->
  </div>
</div>
```

---

## Border Radius Scale

| Token         | Tailwind        | px  | Use                          |
|---------------|-----------------|-----|------------------------------|  
| --radius-sm   | rounded-sm      | 2   | Badges, small tags           |
| --radius-md   | rounded-md      | 6   | Inputs, buttons              |
| --radius-lg   | rounded-lg      | 8   | Cards (compact)              |
| --radius-xl   | rounded-xl      | 12  | Cards (default), modals      |
| --radius-2xl  | rounded-2xl     | 16  | Feature cards, hero sections |
| --radius-full | rounded-full    | 50% | Avatars, pills, FABs        |

---

## Shadow Scale 

```css
--shadow-xs:  0 1px 2px 0 rgb(0 0 0 / 0.05);                          /* Subtle lift */ 
--shadow-sm:  0 1px 3px 0 rgb(0 0 0 / 0.1), 0 1px 2px -1px rgb(0 0 0 / 0.1);  /* Cards */
--shadow-md:  0 4px 6px -1px rgb(0 0 0 / 0.1), 0 2px 4px -2px rgb(0 0 0 / 0.1); /* Dropdowns */
--shadow-lg:  0 10px 15px -3px rgb(0 0 0 / 0.1), 0 4px 6px -4px rgb(0 0 0 / 0.1); /* Modals */
--shadow-xl:  0 20px 25px -5px rgb(0 0 0 / 0.1), 0 8px 10px -6px rgb(0 0 0 / 0.1); /* Popovers */
--shadow-2xl: 0 25px 50px -12px rgb(0 0 0 / 0.25);                     /* Dialogs */
```

| Component    | Shadow    |
|-------------|-----------|
| Card        | shadow-sm |
| Dropdown    | shadow-md |
| Modal       | shadow-lg |
| Popover     | shadow-xl |
| Toast       | shadow-lg |
| Sticky header | shadow-sm (on scroll) |
