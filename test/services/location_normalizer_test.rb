require "test_helper"

class LocationNormalizerTest < ActiveSupport::TestCase
  test "normalize: applies all transformations (lowercase, accents, apostrophes, whitespace)" do
    result = LocationNormalizer.normalize("  MADRID São Paulo O'Neill L'Aquila Montpellier  ")
    assert_equal "madrid sao paulo oneill laquila montpellier", result
  end

  test "normalize: handles nil gracefully" do
    result = LocationNormalizer.normalize(nil)
    assert_equal "", result
  end

  test "normalize: handles empty string" do
    result = LocationNormalizer.normalize("")
    assert_equal "", result
  end
end
