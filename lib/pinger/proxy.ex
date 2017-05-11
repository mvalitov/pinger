defmodule Pinger.Proxy do
  @derive {Poison.Encoder, except: [:ip]}
  defstruct url: nil, ip: nil, country_code: nil, group_id: nil, region_code: nil
end
