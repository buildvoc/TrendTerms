/*
  Project:     TrendTerms
  Name:        TrendTerms_animate.pde
  Purpose:     Methods for zooming, updating the node positions, and getting the node velocities.
  
  Version:     1.0
              
  Author:      Dr. Martin Brändle
               martin.braendle@id.uzh.ch
               
  Address:     University of Zurich
               Zentrale Informatik
               Stampfenbachstr. 73
               8006 Zurich
               Switzerland
  
  Date:        2015-11-07
  Modified:    -
      
  Comment:     -
 
  Uses:        Modules: TrendTerms.pde, TrendTerms_animate.pde, TrendTerms_analyze.pde, 
               TrendTerms_api.pde, TrendTerms_events.pde, TrendTerms_graph_classes.pde, 
               TrendTerms_gui_classes.pde, TrendTerms_init.pde, TrendTerms_io.pde, 
               TrendTerms_node_actions.pde, traer_physics.pde
  
  Copyright:   2015, University of Zurich, IT Services
  License:     The TrendTerms code is Open Source Software. It is released under the 
               GNU GPL (General Public License). For more information, see 
               http://www.opensource.org/licenses/gpl-license.php
               
               THE TrendTerms code IS PROVIDED TO YOU "AS IS", AND WE MAKE NO EXPRESS 
               OR IMPLIED WARRANTIES WHATSOEVER WITH RESPECT TO ITS FUNCTIONALITY, OPERABILITY, 
               OR USE, INCLUDING, WITHOUT LIMITATION, ANY IMPLIED WARRANTIES OF MERCHANTABILITY, 
               FITNESS FOR A PARTICULAR PURPOSE, OR INFRINGEMENT. WE EXPRESSLY DISCLAIM ANY 
               LIABILITY WHATSOEVER FOR ANY DIRECT, INDIRECT, CONSEQUENTIAL, INCIDENTAL OR SPECIAL 
               DAMAGES, INCLUDING, WITHOUT LIMITATION, LOST REVENUES, LOST PROFITS, LOSSES RESULTING 
               FROM BUSINESS INTERRUPTION OR LOSS OF DATA, REGARDLESS OF THE FORM OF ACTION OR LEGAL 
               THEORY UNDER WHICH THE LIABILITY MAY BE ASSERTED, EVEN IF ADVISED OF THE POSSIBILITY 
               OR LIKELIHOOD OF SUCH DAMAGES. 
               
               By using this code, you agree to the specified terms.             
  
  Requires:    Processing Development Environment (PDE), http://www.processing.org/
  Generates:   The PDE exports (menu File > Export) code and data to a web-export directory. 
*/

void doZoom()
{
  switch (hovered_object)
  { 
    case 1000001: // zoom in
      if (zoom < 1600) 
      {
        zoom = zoom + zoom_change;
        fscale = fscale_initial * zoom / 100.0;
        x_offset = x_offset - canvas_width * zoom_change / 200;
        y_offset = y_offset - canvas_height * zoom_change / 200;
      }
      break;
    case 1000003: // zoom out
      if (zoom > 50)
      {
        zoom = zoom - zoom_change;
        fscale = fscale_initial * zoom / 100.0;
        x_offset = x_offset + canvas_width * zoom_change / 200;
        y_offset = y_offset + canvas_height * zoom_change / 200;
      }
      break;
    
    default: 
      zoom_locked = false;
      break;
  }
}

void zoomIn()
{
  float zoom_diff = zoom * (1.0 - zoom_factor);
  zoom = zoom * zoom_factor;
  fscale = fscale * zoom_factor;
  x_offset = x_offset + canvas_width * zoom_diff / 200;
  y_offset = y_offset + canvas_height * zoom_diff / 200;
  
  if (fscale < fscale_initial)
  {
    zoom = zoom_initial;
    fscale = fscale_initial;
    x_offset = x_offset_initial;
    y_offset = y_offset_initial;
    animate_zoomin = false;
  }
}

// update the node positions from particle positions of physics simulation
void updateNodes() {
  for (int i = 0; i < node_count; i++) {
    Node node = (Node) nodes.get(i);
    Particle p = ps.getParticle(i);
    node.setPosition(p.position.x, p.position.y);    
  }
}

// method for centering graph to its centroid
void updateCentroid() {
  float xMin =  999999.9; //Float.POSITIVE_INFINITY,
  float xMax = -999999.9; //Float.NEGATIVE_INFINITY,
  float yMin =  999999.9; //Float.POSITIVE_INFINITY,
  float yMax = -999999.9; //Float.NEGATIVE_INFINITY;

  for (int i = 0; i < ps.numberOfParticles(); i++)
  {
    Particle p = ps.getParticle(i);
    xMax = max(xMax, p.position.x);
    xMin = min(xMin, p.position.x);
    yMin = min(yMin, p.position.y);
    yMax = max(yMax, p.position.y);
  }
  
  float deltaX = xMax - xMin;
  float deltaY = yMax - yMin;
  
  if ( deltaY > deltaX ) {
    centroid.setTarget(xMin + 0.5 * deltaX, yMin + 0.5 * deltaY, 1);
  } else {
    centroid.setTarget(xMin + 0.5 * deltaX, yMin + 0.5 * deltaY, 1);
  }
}

float getTotalVelocity(float x_off, float y_off)
{
  float total_velocity = 0;
  
  for (int i = 0; i < ps.numberOfParticles(); i++)
  {
    Particle p = ps.getParticle(i);
    float velocity_x = p.velocity.x;
    float velocity_y = p.velocity.y;

    Node node = (Node) nodes.get(i);

    stroke(40);
    strokeWeight(0.1);
    float vx = x_off + (node.x + 10*velocity_x) * fscale;
    float vy = y_off + (node.y + 10*velocity_y) * fscale;
    line(x_off + node.x * fscale,y_off + node.y * fscale, vx, vy);

    float vel = velocity_x * velocity_x + velocity_y * velocity_y;
    total_velocity += vel;
  }
  return total_velocity;
}