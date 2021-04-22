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