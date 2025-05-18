local Recolector = {};
function Recolector.Collect(Config)
  local instance = {};
  instance.TargetQty = 0;
  for _ in pairs(Config.Targets) do
    instance.TargetQty = instance.TargetQty + 1;
  end
  instance.Count = 0;
  instance.Collected = {};
  instance.Completed = false;

  local startTick = tick();
  local found = {};

  while tick() - startTick < Config.Timeout and not instance.Completed do
    for _, v in ipairs(getgc(true)) do
      if type(v) == "function" then
        local info = getinfo(v);
        if info then
          for targetKey, targetData in pairs(Config.Targets) do
            if not found[targetKey] then
              local match = true;

              for propKey, propValue in pairs(targetData) do
                if propKey == "constants" and type(propValue) == "table" then
                  for cIx, cV in pairs(propValue) do
                    if getconstant(v, cIx) ~= cV then
                      match = false;
                      break;
                    end
                  end
                elseif propKey == "upvalues" and type(propValue) == "table" then
                  for cIx, cV in pairs(propValue) do
                    if getupvalue(v, cIx) ~= cV then
                      match = false;
                      break;
                    end
                  end
                elseif info[propKey] ~= propValue then
                  match = false;
                  break;
                end
              end

              if match then
                instance.Collected[targetKey] = v;
                found[targetKey] = true;
                instance.Count = instance.Count + 1;
              end
            end
          end
        end
        
        if instance.Count == instance.TargetQty then
          instance.Completed = true;
          break;
        end
      end
    end
    wait(0.1);
  end

  return instance;
end

print("Recolector loaded.");
