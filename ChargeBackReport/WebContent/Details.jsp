<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
	pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<%@ page
	import="org.cloudfoundry.client.lib.CloudCredentials, org.cloudfoundry.client.lib.CloudFoundryClient, org.cloudfoundry.client.lib.StartingInfo, org.cloudfoundry.client.lib.domain.CloudApplication, org.cloudfoundry.client.lib.domain.CloudOrganization, org.cloudfoundry.client.lib.domain.CloudService, org.cloudfoundry.client.lib.domain.CloudSpace, org.cloudfoundry.client.lib.domain.InstanceInfo, org.cloudfoundry.client.lib.domain.InstanceStats"%>
<%@ page
	import="java.text.DecimalFormat, java.net.MalformedURLException, java.net.URI, java.net.URL, java.util.ArrayList, java.util.List"%>

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<script
	src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/2.2.1/Chart.js"></script>
<script
	src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/2.2.1/Chart.bundle.js"></script>
<script
	src="http://ajax.googleapis.com/ajax/libs/jquery/1.9.1/jquery.min.js"></script>
<title>PWS</title>
</head>
<body>

	<h1 style="margin: 0px;">Welcome to Pivotal Cloud Services</h1>
	

	<%
        String target = request.getParameter("url");
        String user = request.getParameter("username");
        String password = request.getParameter("password");
        
        DecimalFormat df=new DecimalFormat("0.000000");
         
        
        CloudCredentials credentials = new CloudCredentials(user, password);
        CloudFoundryClient client = new CloudFoundryClient(credentials, URI.create(target).toURL());
        client.login();
        
        
        Integer memoryquota = (int) client.getQuotaByName("trial", true).getMemoryLimit();
        List<Integer> diskquota = new ArrayList<Integer>();
        
        List<Integer> diskconsumed = new ArrayList<Integer>();
        List<Integer> memoryconsumed = new ArrayList<Integer>();
        List<Double> cpuconsumed = new ArrayList<Double>();
        List<String> appname = new ArrayList<String>();
        int a = 0;
        
        
        for (CloudApplication app : client.getApplications()) {
        	appname.add(a, app.getName());
        	diskquota.add(a, app.getDiskQuota());
        	cpuconsumed.add( client.getApplicationStats(app.getName()).getRecords().get(0).getUsage().getCpu());
        	diskconsumed.add((int)((client.getApplicationStats(app.getName()).getRecords().get(0).getUsage().getDisk())/1024)/1024);
        	memoryconsumed.add((int)((client.getApplicationStats(app.getName()).getRecords().get(0).getUsage().getMem())/1024)/1024);
        	
        	a++;
        }
        a=0;
        /*out.println(memoryquota);
        out.println(appname);
        out.println(diskquota);
        out.println(cpuconsumed);
        out.println(diskconsumed);
        out.println(memoryconsumed);*/
        
        String label = "\"Unutilised\"";
        for (String app : appname) {
        	label = label + ",\""+app+"\"";
        }
        String memoryU = "";
        int c = 0;
        Integer memoryfree = memoryquota;
        for (Integer mem : memoryconsumed) {
        	memoryfree = memoryfree - mem;
        	memoryU = memoryU + mem;
        	if(c<memoryconsumed.size()-1){
        		memoryU = memoryU + ",";
        	}
        	c++;
        }
        c=0;
        String memory =memoryfree.toString();
        for (Integer mem : memoryconsumed) {
        	memory = memory + ","+mem.toString();
        }
        
        String applabel = "";
        int b = 0;
        for (String apps : appname) {
        	applabel = applabel + "\""+apps+"\"";
        	if(b<appname.size()-1){
        		applabel = applabel + ",";
        	}
        	b++;
        }
        b = 0;
        
        String cpu;
        Double cpufree = 100.0;
        for (Double cpucon : cpuconsumed) {
        	cpufree = cpufree - cpucon;
        }
        //cpu = cpufree.toString();
        cpu = df.format(cpufree); 
        String cpuU = "";
        int d = 0;
        for (Double cpucon : cpuconsumed) {
        	cpu = cpu + "," + df.format(cpucon);;
        	cpuU = cpuU + df.format(cpucon);
        	if(d<cpuconsumed.size()-1){
        		cpuU = cpuU + ",";
        	}
        	d++;
        }
        d = 0;
        %>
        
        
        <table>
        <tr>
        <th colspan="2">
        <h2>Memory Consumption:</h2>
        </th>
        <th colspan="2">
        <h2>CPU Consumption:</h2>
        </th>
        
        </tr>
        <tr>
        <th>
        Unutilised Memory
        </th>
        <th>
        Utilised Memory
        </th>
        <th>
        Unutilised CPU
        </th>
        <th>
        Utilised CPU
        </th>
        </tr>
        <tr>
        <td>
        <canvas id="memory" width="200px" height="400px"></canvas>
        </td>
        <td>
        <canvas id="memory2" width="200px" height="400px"></canvas>
        </td>
        <td>
        <canvas id="cpu" width="200px" height="400px"></canvas>
        </td>
        <td>
        <canvas id="cpu1" width="200px" height="400px"></canvas>
        </td>
        </tr>
        </table>
        <script type="text/javascript">
        var ctx = document.getElementById("memory");
        var data = {
        	    labels: [
					<%out.print(label);%>
        	    ],
        	    datasets: [
        	        {
        	        	data: [<%out.print(memory);%>],
        	            backgroundColor: [
        	                "#008000",
        	                "#36A2EB",
        	                "#FFCE56"
        	            ],
        	            hoverBackgroundColor: [
        	                "#FF6384",
        	                "#36A2EB",
        	                "#FFCE56"
        	            ]
        	        }]
        	};
        
        var myPieChart = new Chart(ctx,{
            type: 'pie',
            data: data,
            options: {
		        responsive: false
		    }
        });
        var ctx = document.getElementById("memory2");
        var data = {
        	    labels: [
					<%out.print(applabel);%>
        	    ],
        	    datasets: [
        	        {
        	        	data: [<%out.print(memoryU);%>],
        	            backgroundColor: [
        	                "#FF6384",
        	                "#36A2EB",
        	                "#FFCE56"
        	            ],
        	            hoverBackgroundColor: [
        	                "#FF6384",
        	                "#36A2EB",
        	                "#FFCE56"
        	            ]
        	        }]
        	};
        
        var myPieChart = new Chart(ctx,{
            type: 'pie',
            data: data,
            options: {
		        responsive: false
		    }
        });
        
        var ctx = document.getElementById("cpu");
        var data = {
        	    labels: [
					<%out.print(label);%>
        	    ],
        	    datasets: [
        	        {
        	        	data: [<%out.print(cpu);%>],
        	            backgroundColor: [
        	                "#FF6384",
        	                "#36A2EB",
        	                "#FFCE56"
        	            ],
        	            hoverBackgroundColor: [
        	                "#FF6384",
        	                "#36A2EB",
        	                "#FFCE56"
        	            ]
        	        }]
        	};
        
        var myPieChart = new Chart(ctx,{
            type: 'pie',
            data: data,
            options: {
		        responsive: false
		    }
        });
        
        var ctx = document.getElementById("cpu1");
        var data = {
        	    labels: [
					<%out.print(applabel);%>
        	    ],
        	    datasets: [
        	        {
        	        	data: [<%out.print(cpuU);%>],
        	            backgroundColor: [
        	                "#FF6384",
        	                "#36A2EB",
        	                "#FFCE56"
        	            ],
        	            hoverBackgroundColor: [
        	                "#FF6384",
        	                "#36A2EB",
        	                "#FFCE56"
        	            ]
        	        }]
        	};
        
        var myPieChart = new Chart(ctx,{
            type: 'pie',
            data: data,
            options: {
		        responsive: false
		    }
        });
        
        </script>
        
        
   
</body>
</html>