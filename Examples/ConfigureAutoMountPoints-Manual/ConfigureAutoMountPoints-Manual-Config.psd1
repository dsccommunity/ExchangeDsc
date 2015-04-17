###See the following blog post for information on how to use this example:
###http://blogs.technet.com/b/mhendric/archive/2014/10/27/managing-exchange-2013-with-dsc-part-3-automating-mount-point-setup-and-maintenance-for-autoreseed.aspx

@{
    AllNodes = @(
        @{
            NodeName    = 'e15-1'
            DiskToDBMap = 'DB1,DB2','DB3,DB4'
        }

        @{
            NodeName    = 'e15-2'
            DiskToDBMap = 'DB1,DB2','DB3,DB4'
        }
    );
}