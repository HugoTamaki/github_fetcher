module ApplicationHelper
  def bootstrap_class_for(flash_type)
    {
      notice: "success",
      alert: "warning",
      error: "danger"
    }[flash_type.to_sym] || "info"
  end
end
