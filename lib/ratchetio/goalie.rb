module Goalie
  class CustomErrorPages
    alias_method :orig_render_exception, :render_exception
    
    private

    def render_exception(env, exception)
      exception_data = nil
      begin
        controller = env['action_controller.instance']
        request_data = controller.try(:ratchetio_request_data)
        person_data = controller.try(:ratchetio_person_data)
        exception_data = Ratchetio.report_exception(exception, request_data, person_data)
      rescue => e
        # TODO use logger here?
        puts "[Ratchet.io] Exception while reporting exception to Ratchet.io: #{e}" 
      end
      
      # if an exception was reported, save uuid in the env
      # so it can be displayed to the user on the error page
      if exception_data
        begin
          env['ratchetio.exception_uuid'] = exception_data[:uuid]
        rescue => e
          puts "[Ratchet.io] Exception saving uuid in env: #{e}"
        end
      end

      # now continue as normal
      orig_render_exception(env, exception)
    end
  end
end
