class ConvertAbreviatedToNumber < ApplicationService
  MULTIPLIERS = {
    "k" => 1_000,
    "K" => 1_000,
    "m" => 1_000_000,
    "M" => 1_000_000,
    "b" => 1_000_000_000,
    "B" => 1_000_000_000
  }.freeze

  def call
    abreviated_number = @args[:abreviated_number]
    return 0 if abreviated_number.blank?

    match = abreviated_number.match(/^([\d.,]+)\s*([kKmMbB]?)$/)

    handle_success(result: 0) and return unless match

    result = if match[2].blank?
      match[1]
    else
      number_str = match[1].gsub(",", "")
      multiplier = MULTIPLIERS[match[2]] || 1
      (number_str.to_f * multiplier).to_i
    end

    handle_success(result: result)
  end
end
