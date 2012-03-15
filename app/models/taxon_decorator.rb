#class Spree::Taxon
Taxon.class_eval do
  
  def is_category(root_path)
    if self.parent_id.nil?
        return root_path[1..-1]
    end
    root_path =  "/#{self.id}" + root_path
    Taxon.find(self.parent_id).is_category(root_path)
  end
  
  def has_children?
    unless self.children.blank?
      return true
    else
      return false
    end
  end
  
end