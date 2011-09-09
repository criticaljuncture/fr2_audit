module UrlHelper
  def issue_mods_url(obj)
    "http://www.gpo.gov/fdsys/pkg/FR-#{obj.publication_date.to_s(:iso)}/xml/FR-#{obj.publication_date.to_s(:iso)}.xml"
  end

  def issue_pdf_url(obj)
    "http://www.gpo.gov/fdsys/pkg/FR-#{obj.publication_date.to_s(:iso)}/pdf/FR-#{obj.publication_date.to_s(:iso)}.pdf"
  end

  def issue_bulkdata_url(obj)
    "http://www.gpo.gov/fdsys/bulkdata/FR/#{obj.publication_date.to_s(:year_month)}/FR-#{obj.publication_date.to_s(:db)}.xml"
  end

  def document_mods_url(obj)
    "http://www.gpo.gov/fdsys/granule/FR-#{obj.publication_date.to_s(:iso)}/#{obj.document_number}/mods.xml"
  end

  def document_pdf_url(obj)
    "http://www.gpo.gov/fdsys/pkg/FR-#{obj.publication_date.to_s(:db)}/pdf/#{obj.document_number}.pdf"
  end

  def fr2_url(obj)
    "http://federalregister.gov/a/#{obj.document_number}"
  end
end
