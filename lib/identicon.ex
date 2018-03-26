defmodule Identicon do
  def main(input) do
    input
    |> hash_input
    |> pick_color
    |> build_grid
    |> fill_squares
    |> build_pixel_map
    |> draw_image
    |> save_image(input)
  end

  def save_image(img, filename) do
    File.write("#{filename}.png", img)
  end

  @doc """
    Makes binary from %Identicon.Image pixel_map and color

  ## Examples
    iex> rendered = Identicon.hash_input("wanikoko")
    iex> |> Identicon.pick_color
    iex> |> Identicon.build_grid
    iex> |> Identicon.fill_squares
    iex> |> Identicon.build_pixel_map
    iex> |> Identicon.draw_image
    iex> is_binary(rendered)
    true
  """

  def draw_image(image) do
    img = :egd.create(250, 250)
    fill = :egd.color(image.color)

    Enum.each image.pixel_map, fn({start, stop}) ->
      :egd.filledRectangle(img, start, stop, fill)
    end

    :egd.render(img)
  end

  @doc """
    Makes pixel map from grid

  ## Examples
    iex> image = Identicon.hash_input("wanikoko")
    iex> |> Identicon.build_grid
    iex> |> Identicon.fill_squares
    iex> |> Identicon.build_pixel_map
    iex> Enum.count(image.grid) == Enum.count(image.pixel_map)
    true
  """

  def build_pixel_map(image) do
    pixel_map = Enum.map image.grid, fn({_code, index}) ->
      x = rem(index, 5) * 50
      y = div(index, 5) * 50
      top_left = {x, y}
      bottom_right = {x + 50, y + 50}

      {top_left, bottom_right}
    end

    %{image | pixel_map: pixel_map}
  end

  @doc """
    Calculates wich grid elements need to be filled

  ## Examples
    iex> image = Identicon.hash_input("wanikoko")
    iex> |> Identicon.build_grid
    iex> |> Identicon.fill_squares
    iex> Enum.count(image.grid) < 25
    true
  """

  def fill_squares(image) do
    grid = Enum.filter image.grid, fn({code, _index}) ->
      rem(code, 2) == 0
    end

    %{image | grid: grid}
  end

  @doc """
    Make grid size of 5x5

  ## Examples
    iex> image = Identicon.hash_input("wanikoko")
    iex> grid = Identicon.build_grid(image).grid
    iex> Enum.count(grid)
    25
  """

  def build_grid(image) do
    grid =
      image.hex
      |> Enum.chunk(3)
      |> Enum.map(&mirror_row/1)
      |> List.flatten
      |> Enum.with_index

    %{image | grid: grid}

  end

  @doc """
    Mirroring row values

  ## Examples
    iex> Identicon.mirror_row([128, 64, 32])
    [128, 64, 32, 64, 128]
  """

  def mirror_row(row) do
    elems =
      row
      |> Enum.take(2)
      |> Enum.reverse
    Enum.concat(row, elems)
  end

  @doc """
    Get first 3 numbers as RGB code from %Identicon.Image.hex

  ## Examples
    iex> image = Identicon.hash_input("wanikoko")
    iex> Identicon.pick_color(image).color
    {231, 72, 4}
  """

  def pick_color(image) do
    [r, g, b | _tail] = image.hex

    %{image | color: {r, g, b} }
  end

  @doc """
    Calculating md5 hash of the input string

  ## Examples
    iex> image = Identicon.hash_input("wanikoko")
    iex> image.hex
    [231, 72, 4, 49, 156, 6, 196, 160, 62, 107, 133, 20, 230, 186, 209, 9]
  """

  def hash_input(input) do
    hex =
      :crypto.hash(:md5, input)
      |> :binary.bin_to_list

    %Identicon.Image{hex: hex}
  end
end
