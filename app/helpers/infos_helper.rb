module InfosHelper
  def item_type_id_to_name(id)
    name = ItemType.find(id).name
  end
end
