*----------------------------------------------------------------------*
*   INCLUDE PCREMIN6                                                   *
*----------------------------------------------------------------------*
*OTHERS
TABLES: PCL1,PCL2.
DATA:   SEQNR LIKE PC261-SEQNR.
*INTERNATIONAL INCLUDE
INCLUDE RPC2CD09.  "Cluster CD data definition
INCLUDE RPC2CA00.  "Cluster CA Data-Definition
INCLUDE RPPPXD00.  "Data Definition buffer PCL1/PCL2 Buffer
INCLUDE RPPPXD10.  "Common part buffer PCL1/PCL2
INCLUDE RPPPXM00.  "Buffer Handling routine
*COUNTRY SPECIFIC INCLUDE
INCLUDE PC2RXIN0.  "Cluster IN data definition
INCLUDE RPC2RX09.
*INCLUDE RPC2R1X9.
