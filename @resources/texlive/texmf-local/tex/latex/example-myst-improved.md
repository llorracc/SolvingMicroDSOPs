---
# MyST file using import-based macro configuration
# This is MUCH better than copying 200+ lines of macro definitions!

extends:
  - .econ-ark/generated/econark-macros.yml

title: "Improved MyST Example with Imported Macros"
authors:
  - name: "Econ-ARK Team"
date: 2025-07-15

# Optional: Override specific macros for this file only
math:
  '\SpecialMacro': '\mathcal{S}_{\text{special}}'
---

# Econ-ARK Mathematical Notation Example (Improved MyST)

This document demonstrates the **improved** approach for using Econ-ARK's mathematical notation in MyST markdown. Instead of copying 193 macro definitions into each file, we use MyST's `extends` feature to import them globally.

## Key Improvements

**✅ Clean Files**: No more 200+ lines of frontmatter  
**✅ Single Source**: All macros imported from one shared file  
**✅ Easy Updates**: Change once, affects all files  
**✅ File Overrides**: Can still customize specific macros per file  

## Economic Model Example

The consumer's problem involves optimizing consumption $\cFunc$ subject to budget constraints. 

The Bellman equation is:
$$\vFunc_t(\mLvl_t) = \max_{\cLvl_t} \left\{ \uFunc(\cLvl_t) + \DiscFac \Ex_t[\vFunc_{t+1}(\mLvl_{t+1})] \right\}$$

Where:
- $\vFunc_t(\mLvl_t)$ is the value function  
- $\cLvl_t$ is consumption level (using imported macro)
- $\mLvl_t$ is market resources 
- $\DiscFac$ is the discount factor (using imported macro)
- $\SpecialMacro$ is our file-specific override

## Pattern-Generated Macros Work Too

All the algorithmically generated macros work perfectly:

- Functions: $\cFunc, \mFunc, \vFunc$
- Levels: $\cLvl, \mLvl, \vLvl$ 
- Normalized: $\cNrm, \mNrm, \vNrm$
- Standard deviations: $\cStd, \mStd, \vStd$
- Minimums: $\cMin, \mMin, \vMin$
- Maximums: $\cMax, \mMax, \vMax$

## Cross-References

You can reference equations using MyST syntax: see the Bellman equation above.

## Code Integration

MyST also allows executable content:

```python
# This could be live code in a MyST document
discount_factor = 0.96  # Represents \DiscFac
consumption = 1.5      # Represents \cLvl
```

## Perfect Consistency

This MyST document uses **exactly the same macro names** as LaTeX documents. When you update `.econ-ark/macros.yaml`, both LaTeX and MyST files automatically get the changes.

**No more copying. No more inconsistency. Just import and use!**

## Benefits Summary

1. **Clean**: Files start with actual content, not 200 lines of macros
2. **Maintainable**: Update macros once, all files inherit changes  
3. **Consistent**: Identical notation across LaTeX and MyST
4. **Flexible**: Can override specific macros per file when needed
5. **Modern**: Uses MyST's intended import mechanism 