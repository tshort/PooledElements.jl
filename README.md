# PooledElements

[![Build Status](https://travis-ci.org/tshort/PooledElements.jl.svg?branch=master)](https://travis-ci.org/tshort/PooledElements.jl)

This is an **in-development** package to provide pooled elements. The target use is for columns of DataFrames. The pooled elements provide a mapping to integers. This reduces storage and speeds up times for grouping and sorting. The main types provided are:

* `Pool` -- A container for elements.
* `PooledElement` -- A general element that uses a `Pool` for storage.
* `PooledString` -- An AbstractString that uses a `Pool{AbstractString}` for storage.
* `PooledStringArray` -- An AbstractArray{AbstractString} that uses a vector of integers to reference a pool of strings.

A global string pool is also provided, and many of the PooledString and PooledStringArray methods default to using this global pool. 

The PooledElement, PooledString, and PooledStringArray all support `null` values. A `null` is indicated when the reference to the Pool associated with the element or array is zero. Many of the `Nullable` methods from Base and NullableArrays are supported (like `isnull` and `nullify!`).
