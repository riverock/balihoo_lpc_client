module BalihooLpcClient
  class Api
    attr_accessor :config

    def initialize(config:)
      self.config = config
    end

    def authenticate!
      auth = Request::Authentication.new(api: self)
      auth.authenticate!
    end

    def campaigns(params: {})
      validate_params!(params: params)
      Request::Campaigns.new(api: self, params: params).fetch
    end

    def tactics(campaign_id:, params: {})
      validate_params!(params: params)
      Request::Tactics.new(api: self, params: params, campaign_id: campaign_id).fetch
    end

    def campaigns_with_tactics(params: {})
      validate_params!(params: params)
      Request::CampaignsWithTactics.new(api: self, params: params).fetch
    end

    def metrics(tactic_id:, params: {})
      validate_params!(params: params)
      Request::Metrics.new(api: self, params: params, tactic_id: tactic_id).fetch
    end

    def website_metrics(params: {})
      validate_params!(params: params)
      Request::WebsiteMetrics.new(api: self, params: params).fetch
    end

    private

    def validate_params!(params:)
      if config.location_key.nil? && params[:locations].nil?
        raise ApiOptionError, 'must pass opts[:locations] array since no location_key given'
      end
    end
  end
end
