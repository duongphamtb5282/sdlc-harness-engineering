<!-- sdlc-automation-agent-id: 2061339c42e4c668 -->
# UI Contracts (Runtime-Observed)

Generated: [date]
Last updated: [date]
Source: Live app exploration of [URL]

These are the actual UI contracts as observed from a running application — screen structure, form schemas, API calls, and navigation flows captured at runtime.

> **Privacy note**: If explored against a production instance, this file may reference real data patterns. Review before committing.

---

## Summary

- Screens discovered: [N]
- Forms mapped: [N] 
- API endpoints observed: [N]
- Navigation flows identified: [N]
- Authentication method: [form-based / basic / bearer / SSO / none]

---  

## Screen Inventory

### [Screen Name]

- **Route**: [URL path or pattern]
- **Title**: [page title from DOM]
- **Purpose**: [inferred from content and elements]
- **Key elements**:
  - [forms, tables, data grids, action buttons]
- **Navigation**: leads to → [list of reachable screens]
- **Access**: [public / requires auth / role-restricted]
- **Data displayed**: [entity types shown on this screen]

<!-- Repeat for each discovered screen -->  

---

## Form Schemas

### [Form on Screen Name]

- **Action**: [submit URL/method if observed] 
- **Fields**: 
  | Field Label | Name/ID | Type | Required | Validation | Options/Constraints |
  |---|---|---|---|---|---|
  | [label] | [name attr] | text / email / select / checkbox / date / number | Y/N | [pattern, min, max, minlength] | [dropdown options if select] |

- **Submit behavior**: [observed API call or page navigation] 
- **Client-side validation**: [custom validators observed in DOM/JS]

<!-- Repeat for each form -->  

---

## API Contracts (Runtime-Observed)

### [METHOD] [path]

- **Called from**: [screen name]
- **Request headers**: [content-type, auth headers] 
- **Request body**: [structure summary — field names and types]
- **Response status**: [observed status code]
- **Response body**: [structure summary — field names and types]
- **Auth**: [cookie / bearer token / API key / none]
- **Notes**: [rate limiting observed, caching headers, etc.]

<!-- Repeat for each observed API endpoint -->

---  

## Navigation Map 

[Screen adjacency summary — which screens link to which, primary user flows]

### Primary Flows
1. [Flow name]: [Screen A] → [Screen B] → [Screen C]

### Orphan Screens 
- [Screens reachable only by direct URL, not linked from navigation]

### Dead Links
- [Navigation elements that lead to errors or missing pages]  
