# frozen_string_literal: true

# @abstract Indexes a work and all of its versions, regardless of state. However, if no published version of the work
# exists, only the draft version will be indexed and not the work itself. Given the following scenarios, this is how
# many records in solr you might expect to find:
#
# * Work with one draft version: 1 record (work version only)
# * Work with one published version: 2 records
# * Work with one published version and one draft: 3 records
# * Work with two published versions: 3 records
#

class WorkIndexer
  def self.call(work, commit: false)
    work.versions.map do |version|
      IndexingService.add_document(version.to_solr, commit: false)
    end

    if work.latest_published_version.present?
      IndexingService.add_document(work.to_solr, commit: commit)
    elsif commit
      Blacklight.default_index.connection.commit
    end
  end
end
