class MitStudents < ActiveLdap::Base
  ldap_mapping dn_attribute: "uid", prefix: "ou=users,ou=moira" , scope: :sub
  
  def full_name
    "#{self.givenname} #{self.sn}"
  end
  
  def year
    if self.mitDirStudentYear
      Date.current.year + 4 - self.mitDirStudentYear.to_i + ((Date.current.month > 7)?1:0)
    else
      nil
    end
  end
  
end
