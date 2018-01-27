FDroid and UnifiedNlp for Custom ROMs
=====================================

Download FDroid and UnifiedNlp prebuilt APKs for inclusion in a custom ROM.
This also downloads the GPG armor files of the packages to verify them.

Getting the packages
--------------------

* Add it to your local manifest:

      <?xml version="1.0" encoding="UTF-8"?>
      <manifest>
          <!-- MicroG -->
          <project name="cryptomilk/android_vendor_fdroid" path="vendor/fdroid" remote="github" />
      </manifest>

* After downloading to to the vendor dir and get the packages:

      cd vendor/fdroid
      ./get_packages.sh
