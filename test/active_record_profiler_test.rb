require File.dirname(__FILE__) + '/test_helper.rb'


class ActiveRecordProfilerTest < Test::Unit::TestCase
  def setup
    @collector = ActiveRecordProfiler::Collector.instance
    @test_log = StringIO.new
    ActiveRecord::Base.logger = ActiveSupport::BufferedLogger.new(@test_log)
    ActiveRecord::Base.establish_connection($test_config['test'])
  end
  
  def test_caller_location_appears_in_log
    sql = 'SELECT 1 FROM dummy_logs'
    ActiveRecord::Base.connection.select_value(sql)
    @test_log.rewind
    log_data = @test_log.read
    assert_match Regexp.new(Regexp.quote(sql) + '.*' + Regexp.quote('active_record_profiler_test.rb')), log_data
  end

  def test_profiler_records_query_site
    assert @collector
    @collector.flush_query_sites_statistics
    assert @collector.query_sites.blank?
    sql = 'SELECT 1 FROM dummy_logs'
    ActiveRecord::Base.connection.select_value(sql)
    @test_log.rewind
    log_data = @test_log.read
    assert @collector.query_sites.present?
  end

end
