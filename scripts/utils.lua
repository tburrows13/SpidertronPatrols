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

function table_equals(table1, table2)
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


function table_diff(table1, table2)
  -- Returns a table `diff` indexed by item_name where positive values are the amount in table1 not in table2, negative values are the amount in table2
  diff = {}
  table2 = table.deepcopy(table2)
  for item_name, count1 in pairs(table1) do
    local count2 = table2[item_name] or 0
    if count1 ~= count2 then
      diff[item_name] = count1 - count2
    end
    table2[item_name] = nil
  end

  -- Only iterates through what is left of table 2, so all items are not in table1
  for item_name, count2 in pairs(table2) do
    diff[item_name] = -count2
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
