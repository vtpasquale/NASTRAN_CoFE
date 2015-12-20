document.write('<nav class="navbar navbar-inverse">');
  document.write('<div class="container-fluid">');
    document.write('<div class="navbar-header">');
      document.write('<button type="button" class="navbar-toggle" data-toggle="collapse" data-target="#myNavbar">');
        document.write('<span class="icon-bar"></span>');
        document.write('<span class="icon-bar"></span>');
        document.write('<span class="icon-bar"></span>');
      document.write('</button>');
      document.write('<a href="index.html" class="pull-left"><img style="max-width:125px; margin-top: 3px;" src="CoFEweb.png"></a>');
    document.write('</div>');
    document.write('<div class="collapse navbar-collapse" id="myNavbar">');
      document.write('<ul class="nav navbar-nav">');
        document.write('<li><a href="index.html">Home</a></li>');
		
        document.write('<li class="dropdown">');
          document.write('<a class="dropdown-toggle" data-toggle="dropdown" href="#">Bulk Data Inputs<span class="caret"></span></a>');
          document.write('<ul class="dropdown-menu">');
            document.write('<li><a href="BLIQ.html">BLIQ</a></li>');
            document.write('<li><a href="CBEAM.html">CBEAM</a></li>');
            document.write('<li><a href="CELAS2.html">CELAS2</a></li>');
            document.write('<li><a href="CMASS1.html">CMASS1</a></li>');
			document.write('<li><a href="CONM2.html">CONM2</a></li>');
            document.write('<li><a href="CORD2R.html">CORD2R</a></li>');
			document.write('<li><a href="CQUAD4.html">CQUAD4</a></li>');
            document.write('<li><a href="CROD.html">CROD</a></li>');
            document.write('<li><a href="FORCE.html">FORCE</a></li>');
            document.write('<li><a href="GRAV.html">GRAV</a></li>');
            document.write('<li><a href="GRDSET.html">GRDSET</a></li>');
            document.write('<li><a href="GRID.html">GRID</a></li>');
            document.write('<li><a href="MAT1.html">MAT1</a></li>');
			document.write('<li><a href="MOMENT.html">MOMENT</a></li>');
            document.write('<li><a href="PBEAM.html">PBEAM</a></li>');
            document.write('<li><a href="PBEAML.html">PBEAML</a></li>');
            document.write('<li><a href="PMASS.html">PMASS</a></li>');
            document.write('<li><a href="PROD.html">PROD</a></li>');
			document.write('<li><a href="PSHELL.html">PSHELL</a></li>');
            document.write('<li><a href="RBE2.html">RBE2</a></li>');
            document.write('<li><a href="RBE3.html">RBE3</a></li>');
            document.write('<li><a href="SPC1.html">SPC1</a></li>');
          document.write('</ul>');
        document.write('</li>');
				
		document.write('<li class="dropdown">');
          document.write('<a class="dropdown-toggle" data-toggle="dropdown" href="#">Examples<span class="caret"></span></a>');
          document.write('<ul class="dropdown-menu">');
		    document.write('<li><a href="#"><b>ANALYSIS EXAMPLES</b></a></li>');
			document.write('<li><a href="tenBarTrussAnalysis.html">Ten Bar Truss</a></li>');
			document.write('<li><a href="svanbergAnalysis.html">Svanberg Beam</a></li>');
			document.write('<li><a href="seventyTwoBarAnalysis.html">Seventy Two Bar Truss</a></li>');
			document.write('<li><a href="joinedWingSensorCraftAnalysis.html">Joined-Wing Scaled Model</a></li>');
			
			document.write('<li class="divider"></li>');
			
		    document.write('<li><a href="#"><b>OPTIMIZATION EXAMPLES</b></a></li>');
			document.write('<li><a href="tenBarTrussOptimization.html">Ten Bar Truss Sizing</a></li>');
			document.write('<li><a href="tenBarTrussShapeOpt.html">Ten Bar Truss Shape &amp; Sizing</a></li>');
			document.write('<li><a href="svanbergBeamOpt.html">Svanberg Beam</a></li>');
			document.write('<li><a href="seventyTwoBarTrussOpt.html">Seventy Two Bar Truss</a></li>');
			
          document.write('</ul>');
        document.write('</li>');
		
      document.write('</ul>');
	  
	  
      document.write('<ul class="nav navbar-nav navbar-right">');
	    document.write('<li><a target="_blank" href="https://github.com/vtpasquale/NASTRAN_CoFE"><span class="glyphicon glyphicon-cloud-download"></span>  View on GitHub</a></li>');
        document.write('<li><a target="_blank" href="http://aricciardi.weebly.com/"><span class="glyphicon glyphicon-home"></span>  Author Home</a></li>');
	  document.write('</ul>');
	  
    document.write('</div>');
  document.write('</div>');
document.write('</nav>');