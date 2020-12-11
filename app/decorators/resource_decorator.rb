# frozen_string_literal: true

class ResourceDecorator < SimpleDelegator
  # @returns an appropriately-decorated object. This is a factory method
  def self.decorate(resource)
    return WorkVersionDecorator.new(resource) if resource.is_a? WorkVersion
    return WorkDecorator.new(resource) if resource.is_a? Work
    return CollectionDecorator.new(resource) if resource.is_a? Collection

    raise ArgumentError, "I don't know how to decorate a #{resource.class.name}"
  end

  def partial_name
    model_name.singular
  end

  def display_work_type
    return unless respond_to?(:work_type)

    Work::Types.display(work_type)
  end

  def display_published_date
    return unless respond_to?(:published_date)

    EdtfDate.humanize(published_date)
  end

  def display_doi
    return if resource_with_doi.doi.blank?

    MintingStatusDoiComponent.new(resource: resource_with_doi)
  end

  def visibility_badge
    VisibilityBadgeComponent.new(work: self)
  end

  def first_creators
    if creator_aliases.length > 3
      creator_aliases.take(3) + ['&hellip;']
    else
      creator_aliases.take(3)
    end
  end

  # @note Google Scholar prefers the year alone
  def published_date_or_deposited_year
    return deposited_at.year unless EdtfDate.valid?(published_date)

    Date.edtf(published_date).year
  end
end
