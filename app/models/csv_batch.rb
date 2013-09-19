class CsvBatch < ActiveRecord::Base
  has_many :csv_batch_rows
end
