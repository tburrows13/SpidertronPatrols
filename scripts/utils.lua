---@param array table
---@param element any
---@param remove boolean?
---@return boolean
function contains(array, element, remove)
  for i, value in pairs(array) do
    if value == element then
      if remove then table.remove(array, i) end
      return true
    end
  end
  return false
end

function contains_key(array, element, remove)
  for key, _ in pairs(array) do
    if key == element then
      if remove then table.remove(array, key) end
      return true
    end
  end
  return false
end

function content_equals(table1, table2)
  table2 = table.deepcopy(table2)
  for item_name, count1 in pairs(table1) do
    local count2 = table2[item_name] or 0
    if count1 ~= count2 then
      return false
    end
    table2[item_name] = nil
  end

  return next(table2) == nil
end

function table_equals(table1, table2)
  table2 = table.deepcopy(table2)
  for index, contents1 in pairs(table1) do
    local contents2 = table2[index] or {}
    if not content_equals(contents1, contents2) then
      return false
    end
    table2[index] = nil
  end
  return next(table2) == nil
end

function table_diff(table1, table2)
  -- Returns a table `diff` indexed by item_name, then by quality_name where positive values are the amount in table1 not in table2, negative values are the amount in table2
  diff = {}
  table2 = table.deepcopy(table2)
  for item_name, quality_dict in pairs(table1) do
    for quality_name, count1 in pairs(quality_dict) do
      local count2 = table2[item_name] and table2[item_name][quality_name] or 0
      if count1 ~= count2 then
        if not diff[item_name] then diff[item_name] = {} end
        diff[item_name][quality_name] = count1 - count2
      end
      if table2[item_name] then table2[item_name][quality_name] = nil end
    end
  end

  -- Only iterates through what is left of table2, so all items are not in table1
  for item_name, count2 in pairs(table2) do
    for quality_name, count in pairs(count2) do
      if not diff[item_name] then diff[item_name] = {} end
      diff[item_name][quality_name] = -count
    end
  end
  return diff
end

function filter_table_diff(table1, table2)
  -- Returns a table `diff` containing subtables `added` and `removed`
  local diff = {}
  table2 = table.deepcopy(table2)
  for index, filter in pairs(table1) do
    if not table2[index] then
      diff[index] = filter
    end
    table2[index] = nil
  end
  -- Only iterates through what is left of table2, so all filters are not in table1
  for index, filter in pairs(table2) do
    diff[index] = -1
  end

  return diff
end

-- From https://github.com/factoriolib/flib/blob/master/table.lua#L173
function for_n_of(tbl, from_k, n, callback)
  local delete
  local prev
  local abort
  local result = {}

  -- run `n` times
  for _ = 1, n, 1 do
    local v
    if not delete then
      prev = from_k
    end
    from_k, v = next(tbl, from_k)
    if delete then
      tbl[delete] = nil
    end

    if from_k then
      result[from_k], delete, abort = callback(v, from_k)
      if delete then
        delete = from_k
      end
      if abort then break end
    else
      return from_k, result, true
    end
  end

  if delete then
    tbl[delete] = nil
    from_k = prev
  elseif abort then
    from_k = prev
  end
  return from_k, result, false
end
