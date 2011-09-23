module CallbacksHelper
  extend ActiveSupport::Concern

  included do
    [ :before_create,  :after_create,
      :before_update,  :after_update,
      :before_save,    :after_save,
      :before_destroy, :after_destroy].each do |callback|
      callback_method = "#{callback}_callback"
      send(callback, callback_method)
      define_method(callback_method) { history << callback.to_sym }
    end
  end

  def history
    @history ||= []
  end

  def clear_history
    @history = nil
  end
end
