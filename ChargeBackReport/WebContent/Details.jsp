<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
	pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<%@ page
	import="org.cloudfoundry.client.lib.CloudCredentials, org.cloudfoundry.client.lib.CloudFoundryClient, org.cloudfoundry.client.lib.StartingInfo, org.cloudfoundry.client.lib.domain.CloudApplication, org.cloudfoundry.client.lib.domain.CloudOrganization, org.cloudfoundry.client.lib.domain.CloudService, org.cloudfoundry.client.lib.domain.CloudSpace, org.cloudfoundry.client.lib.domain.InstanceInfo, org.cloudfoundry.client.lib.domain.InstanceStats"%>
<%@ page
	import=" java.net.MalformedURLException, java.net.URI, java.net.URL, java.util.ArrayList, java.util.List"%>

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

	<h1>Welcome to Pivotal Cloud Services</h1>
	<br />

	<%
        String target = request.getParameter("url");
        String user = request.getParameter("username");
        String password = request.getParameter("password");
        
        CloudCredentials credentials = new CloudCredentials(user, password);
        CloudFoundryClient client = new CloudFoundryClient(credentials, URI.create(target).toURL());
        client.login();
        
        
        %>
	<h2>Spaces:</h2>
	<ul>
		<%
        for (CloudSpace space : client.getSpaces()) {
        	%>
		<li>
			<%
            
        	out.println(space.getName());
        	%>
		</li>
		<%
        }
        
        %>

	</ul>
	<h2>Applications:</h2>
	<br />
	<%
	for (CloudApplication app : client.getApplications()) {
		
		out.println(app.getName()+"<br />");
		%>
		
		<canvas id="<%out.print(app.getName());%>" width="200px" height="400px"></canvas>
		<script>
		var a="<%out.print(client.getApplicationStats(app.getName()).getRecords().get(0).getUsage().getDisk());%>";
		a = (a/1024)/1024
		var b="<%out.print(client.getApplicationStats(app.getName()).getRecords().get(0).getDiskQuota());%>";
		b = (b/1024)/1024
		var ctx = document.getElementById("<%out.print(app.getName());%>");
		var myChart = new Chart(ctx, {
		    type: 'bar',
		    data: {
		        labels: ["Allotted", "Consumed"],
		        datasets: [{
		            label: 'Disk Quota',
		            data: [b, a],
		            backgroundColor: [
		                'rgba(255, 99, 132, 0.2)',
		                'rgba(54, 162, 235, 0.2)'
		            ],
		            borderColor: [
		                'rgba(255,99,132,1)',
		                'rgba(54, 162, 235, 1)'
		            ],
		            borderWidth: 1
		        }]
		    },
		    options: {
		        responsive: false
		    }
		});
		</script>
		
		
		
		<%
		
	}
	
	%>

	



</body>
</html>