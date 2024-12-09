// Code your testbench here
// or browse Examples
// Code your testbench here
// or browse Examples
class Stimulus;
  rand bit [0:7] queue_data[$];    
  rand opcode_u op;                
  rand int new_size;
   

  // Function to generate a random queue
  function void gen_random_queue();
    new_size = $urandom_range(1, 10);  
    for (int i = 0; i < new_size; i++) begin
      queue_data[i] = $urandom_range(0, 100);  
    end
  endfunction

  // Function to generate alternating sequence (4 and 5)
  function void gen_alternating_seq();
    new_size = $urandom_range(3, 10);  
    for (int i = 0; i < new_size; i++) begin
      queue_data[i] = (i % 2 == 0) ? 4 : 5;  
    end
  endfunction

  // Function to generate same sequence (all 4)
  function void gen_same_seq();
    new_size = $urandom_range(3, 10);  
    for (int i = 0; i < new_size; i++) begin
      queue_data[i] = 4;  
    end
  endfunction

  // Function to generate one element
  function void gen_one_element();
    queue_data[0] = 3;         
  endfunction

  // Function to generate two elements
  function void gen_two_element();
    queue_data[0] = 3;         
    queue_data[1] = 6;         
  endfunction

  // Function to generate three elements
  function void gen_three_elements();
    queue_data[0] = 4;         
    queue_data[1] = 6;        
    queue_data[2] = 2;        
  endfunction

  // Function to generate random inputs based on the operation type
  function void generate_inputs();
    //opcode_u op = int'($urandom_range(0, 6));
 op = opcode_u'($urandom_range(0, 6));
    case ($urandom_range(0, 5))  
      0: gen_random_queue();       
      1: gen_alternating_seq();    
      2: gen_same_seq();           
      3: gen_one_element();        
      4: gen_two_element();        
      5: gen_three_elements();     
      default: gen_random_queue(); 
    endcase
    $display("Generated Queue: %p", queue_data);
  endfunction 
   endclass


class Monitor;

  // Function to check if the output from DUT matches the expected output
  function void check_output(list_q expected_output, list_q dut_output, string operation);
//     if (expected_output.size() != dut_output.size()) begin
//       $display("Operation %s FAILED: size mismatch", operation);
//       $display("Expected size: %0d, Got size: %0d", expected_output.size(), dut_output.size());
//     end else 
    if (expected_output == dut_output) begin
      $display("expected %p",expected_output);
      $display("actual %p",dut_output);
      $display("Operation %s PASSED", operation);
      
    end else begin
      $display("Operation %s FAILED", operation);
      $display("Expected: %p", expected_output);
      $display("Got: %p", dut_output);
    end
  endfunction

 
  
  // Function to initialize or reset the queue with new data
function list_q expected_new(bit[0:7] queue[$], bit[0:7] input_data[$]);
    list_q result;
    int i;
queue.delete();
    foreach(input_data[i]) begin
        queue.push_back(input_data[i]);
    end
result = queue;
    return result;
endfunction
  
  // Function to traverse and return all elements of the queue
  function list_q expected_traverse(bit[0:7] queue[$]);
    list_q result;
    foreach(queue[i]) begin
      result.push_back(queue[i]);  // Traverse through and store all elements
    end
    return result;
  endfunction

  // Function to find a value in the queue and return its index
  function list_q expected_find(bit[0:7] queue[$], int value);
    list_q result;
    int idx = -1;
    foreach(queue[i]) begin
      if(queue[i] == value) begin
        idx = i;  
        break;
      end
    end
    result.push_back(idx);  
    return result;
  endfunction
  
//insert a value
  function list_q expected_insert(bit[0:7] queue[$], bit[0:7] prev_data =0, bit[0:7] next_data=0);
    list_q result;
    int prev_data_index = -1;

    foreach(queue[i]) begin
        if(queue[i] == prev_data) begin
            prev_data_index = i;
            break;
        end
    end
 if (prev_data_index != -1) begin
     
        result = queue;
        
       result.push_back(0);  
        
        
        for (int j = result.size() - 2; j > prev_data_index; j--) begin
            result[j + 1] = result[j];
        end
        
       
        result[prev_data_index + 1] = next_data;
        
    end else begin
      
        $display("prev_data not found, no insertion performed");
        result = queue;
    end
    return result;
endfunction



  //Function to delete a data from the queue
  function list_q expected_delete(bit[0:7] queue[$], bit[0:7] data);
    list_q result;
    int flag=0;
    foreach(queue[i]) begin
      if((queue[i] != data) || flag==1) begin
        result.push_back(queue[i]);
      end
      else
        flag=1;
    end
    return result;
  endfunction

  // Function to get the length of the queue
  function list_q expected_len(bit[0:7] queue[$]);
    list_q result;
    result.push_back(queue.size());  
    return result;
  endfunction

  // Function to reverse the queue
  function list_q expected_reverse(bit[0:7] queue[$]);
    list_q result;
    for(int i = queue.size()-1; i >= 0; i--) begin
      result.push_back(queue[i]);  
    end
    return result;
  endfunction  
 endclass




module tb();
  bit [0:7] dut_output[$];
  bit [0:7] expected_output[$];

  // Declare variables and instances
  bit [0:7] queue_[$];   
  int a, b, c, d;
  Stimulus stim;
  DUT dut;
  Monitor monitor; 
  opcode_u op;

  //Function to check if an element exists in the queue
  function bit exists(bit [0:7] q[$], int value);
    if (q.size() == 0) return 0; 
    foreach(q[i]) begin
      if (q[i] == value)
        return 1; 
    end
    return 0; 
  endfunction

  initial begin
    // Initialize instances
    dut = new();
    stim = new();
    monitor = new();  // Initialize monitor
    
    
    // Repeat 20 times to simulate random operations
    repeat(20) begin
      stim.generate_inputs(); 
      queue_ = stim.queue_data;
      op = stim.op;

      // Display and run NEW operation
      $display("Running NEW operation with data: %p", queue_);
      dut_output = dut.run(NEW, queue_);
      expected_output = monitor.expected_traverse(queue_);
      monitor.check_output(expected_output, dut_output, "NEW");

      // Generate random data for operations
      a = $urandom_range(0, 100);
      b = $urandom_range(0, 100);
      c = ($urandom_range(0, 1) == 0) ? queue_[$urandom_range(0, queue_.size())] : $urandom_range(0, 100); 
      d = ($urandom_range(0, 1) == 0) ? queue_[$urandom_range(0, queue_.size())] : $urandom_range(0, 100);
     

      // Randomly pick an operation to run
      case($urandom_range(0, 6))
        0: begin
          $display("Running NEW");
          dut_output = dut.run(NEW, queue_);
          expected_output = monitor.expected_traverse(queue_);
          monitor.check_output(expected_output, dut_output, "NEW");
        end
        1: begin
          $display("Running TRAVERSE");
          dut_output = dut.run(TRAVERSE);
          expected_output = monitor.expected_traverse(queue_);
          monitor.check_output(expected_output, dut_output, "TRAVERSE");
        end
        2: begin
          // Check find from queue or outside
          if (exists(queue_, c)) begin
            $display("Running FIND with data: %0d", c);
            dut_output = dut.run(FIND, {c});
            expected_output = monitor.expected_find(queue_, c);
            monitor.check_output(expected_output, dut_output, "FIND");
          end else begin
            $display("Running FIND with data: %0d (not in queue)", c);
            dut_output = dut.run(FIND, {c});
            expected_output = monitor.expected_find(queue_, c);
            monitor.check_output(expected_output, dut_output, "FIND");
          end
        end
        3: begin
          // INSERT operation: Check if c is from queue or outside
          if (exists(queue_, c)) begin
            $display("Running INSERT with data: %0d, %0d", c, b);
            dut_output = dut.run(INSERT, {c, b});
            expected_output = monitor.expected_insert(queue_, c, b);
            monitor.check_output(expected_output, dut_output, "INSERT");
          end else begin
            $display("Running INSERT with data: %0d (new value), %0d", c, b);
            dut_output = dut.run(INSERT, {c, b});
            expected_output = monitor.expected_insert(queue_, c, b);
            monitor.check_output(expected_output, dut_output, "INSERT");
          end
        end
        4: begin
          // DELETE operation: Check if d exists in the queue
          if (exists(queue_, d)) begin
            $display("Running DELETE with data: %0d", d);
            dut_output = dut.run(DELETE, {d});
            expected_output = monitor.expected_delete(queue_, d);
            monitor.check_output(expected_output, dut_output, "DELETE");
          end else begin
            $display("Sorry, the value %0d doesn't exist in the queue.", d);
          end
        end
        5: begin
          $display("Running LEN");
          dut_output = dut.run(LEN);
          expected_output = monitor.expected_len(queue_);
          monitor.check_output(expected_output, dut_output, "LEN");
        end
        6: begin
          $display("Running REVERSE");
          dut_output = dut.run(REVERSE);
          expected_output = monitor.expected_reverse(queue_);
          monitor.check_output(expected_output, dut_output, "REVERSE");
        end
        default: begin
          $display("Invalid Operation");
        end
   endcase
     end
    
    $display("Guys, time to do some directed test as well");
    // TC1 NEW {10}
dut_output = dut.run(NEW, {10}); 
monitor.check_output(monitor.expected_new({}, {10}), dut_output, "NEW"); // Test case 1

// TC2 NEW {10, 20}
dut_output = dut.run(NEW, {10, 20}); 
monitor.check_output(monitor.expected_new({}, {10, 20}), dut_output, "NEW"); // Test case 2

// TC3 NEW {10, 20, 30}
dut_output = dut.run(NEW, {10, 20, 30}); 
monitor.check_output(monitor.expected_new({}, {10, 20, 30}), dut_output, "NEW"); // Test case 3

// TC4 NEW {30, 30, 30, 30}
dut_output = dut.run(NEW, {30, 30, 30, 30}); 
monitor.check_output(monitor.expected_new({}, {30, 30, 30, 30}), dut_output, "NEW"); // Test case 4

// TC5 NEW {10, 20, 10, 20, 10}
dut_output = dut.run(NEW, {10, 20, 10, 20, 10}); 
monitor.check_output(monitor.expected_new({}, {10, 20, 10, 20, 10}), dut_output, "NEW"); // Test case 5

// TC6 NEW {}
dut_output = dut.run(NEW, {}); 
monitor.check_output(monitor.expected_new({}, {}), dut_output, "NEW"); // Test case 6

  
    //tc 7 traverse
    dut.run(NEW,{5});
    monitor.check_output(monitor.expected_traverse({5}),dut.run(TRAVERSE),"TRAVERSE");
    //TC8 TRAVERSE
dut.run(NEW, {16, 32}); monitor.check_output(monitor.expected_traverse({16, 32}), dut.run(TRAVERSE), "TRAVERSE");

//TC9 TRAVERSE
dut.run(NEW, {16, 32, 48}); monitor.check_output(monitor.expected_traverse({16, 32, 48}), dut.run(TRAVERSE), "TRAVERSE");

//TC10 TRAVERSE
dut.run(NEW, {48, 48, 48, 48}); monitor.check_output(monitor.expected_traverse({48, 48, 48, 48}), dut.run(TRAVERSE), "TRAVERSE");

//TC11 TRAVERSE
dut.run(NEW, {16, 32, 16, 32, 16}); monitor.check_output(monitor.expected_traverse({16, 32, 16, 32, 16}), dut.run(TRAVERSE), "TRAVERSE");

//TC12 TRAVERSE
dut.run(NEW, {}); monitor.check_output(monitor.expected_traverse({}), dut.run(TRAVERSE), "TRAVERSE");

// TC13 INSERT {20, 30} 1 item in list
// // Insert 30 after 20. 
// if (queue.size() == 0) begin
//     $display("Error: Cannot insert into an empty list, queue remains empty.");
//     // Ensure the queue remains empty if no elements exist
//     dut_output = dut.run(INSERT, {20, 30});
//   assert(dut_output == 0);  // Assert that no elements were inserted
// end else begin
//     // Insert and verify behavior for non-empty queue
//     dut_output = dut.run(INSERT, {20, 30});
//     monitor.check_output(monitor.expected_new({20}, {30}), dut_output, "INSERT"); // TC14
// end

//tc 14
    dut.run(NEW,{20});
    monitor.check_output(monitor.expected_insert({20},30), dut.run(INSERT,{20,30}), "INSERT");  
//tc 15
 
    dut.run(NEW,{45,86,20});
    monitor.check_output(monitor.expected_insert({45,86,20},45,75), dut.run(INSERT,{45,75}), "INSERT");
// tc 16
    dut.run(NEW,{10,20,30});
    monitor.check_output(monitor.expected_insert({10,20,30},30,40), dut.run(INSERT,{30,40}), "INSERT");
    
//tc 17
    dut.run(NEW,{10,20,30});
    monitor.check_output(monitor.expected_insert({10,20,30},15,25), dut.run(INSERT,{15,25}), "INSERT");
 //tc 18
    dut.run(NEW,{10,20,10,20});
    monitor.check_output(monitor.expected_insert({10,20,10,20},20,25), dut.run(INSERT,{20,25}), "INSERT");
    //tc 19

    dut.run(NEW,{20,20,20});
    monitor.check_output(monitor.expected_insert({20,20,20},20,55), dut.run(INSERT,{20,55}), "INSERT");
//     //tc20
//     dut.run(NEW,{});
//     monitor.check_output(monitor.expected_delete({},10),dut.run(DELETE,{}),"DELETE");
   //tc 21
    dut.run(NEW,{20});
monitor.check_output(monitor.expected_delete({20},20), dut.run(DELETE,{20}), "DELETE");
//tc22
dut.run(NEW,{10});
monitor.check_output(monitor.expected_delete({10},10), dut.run(DELETE,{10}), "DELETE");
//tc23
// dut.run(NEW,{30, 10, 20});
// monitor.check_output(monitor.expected_delete({30,10,20},30), dut.run(DELETE,{30}), "DELETE");
//tc24
// dut.run(NEW,{10, 10});
// monitor.check_output(monitor.expected_delete({10,10},10), dut.run(DELETE,{10}), "DELETE");
//tc25
// dut.run(NEW,{});
// monitor.check_output(monitor.expected_delete({},10), dut.run(DELETE,{10}), "DELETE");
//tc26
dut.run(NEW,{20, 30, 10, 10, 20});
monitor.check_output(monitor.expected_delete({20,30,10,10,20},10), dut.run(DELETE,{10}), "DELETE");
//tc27
//     dut.run(NEW,{20,10,30});
//     monitor.check_output(monitor.expected_find({20,10,30},10),dut.run({FIND,{10}),"FIND");
    
  //tc27
 
    dut.run(NEW,{10});
    monitor.check_output(monitor.expected_find({10},10), dut.run(FIND,{10}), "FIND");
    //TC28
    dut.run(NEW,{10,20});
    monitor.check_output(monitor.expected_find({10,20},10), dut.run(FIND,{10}), "FIND");
    //TC29
    dut.run(NEW,{10,20});
    monitor.check_output(monitor.expected_find({10,20},20), dut.run(FIND,{10}), "FIND");//ERROR
    //TC30
    dut.run(NEW,{10,20,40});
    monitor.check_output(monitor.expected_find({10,20,40},30), dut.run(FIND,{10}), "FIND");//ERROR
    //TC31
    
    dut.run(NEW,{10,10,10});
    monitor.check_output(monitor.expected_find({10,10,10},10), dut.run(FIND,{10}), "FIND");
    //TC32
    
    dut.run(NEW,{5,6,5,6});
    monitor.check_output(monitor.expected_find({5,6,5,6},5), dut.run(FIND,{10}), "FIND");//ERROR
    
    

 //tc33
                  
    dut.run(NEW,{1});                                                                  
                                                                       monitor.check_output(monitor.expected_reverse({1}), dut.run(REVERSE), "REVERSE");           //tc34
    dut.run(NEW,{10,20});                                                                  
                                                                       monitor.check_output(monitor.expected_reverse({10,20}), dut.run(REVERSE), "REVERSE");  
  //tc35
    dut.run(NEW,{10,20,30});                                                                  
                                                                       monitor.check_output(monitor.expected_reverse({10,20,30}), dut.run(REVERSE), "REVERSE");
  //tc36
    
    dut.run(NEW,{10,10,10});                                                                  
                                                                   monitor.check_output(monitor.expected_reverse({10,10,10}), dut.run(REVERSE), "REVERSE");  
    //tc37
    dut.run(NEW,{10,20,10,20});                                                                  
                                                                   monitor.check_output(monitor.expected_reverse({10,20,10,20}), dut.run(REVERSE), "REVERSE");
//     //tc38
//     dut.run(NEW,{});                                                                  
//                                                                    monitor.check_output(monitor.expected_reverse({}), dut.run(REVERSE), "REVERSE");
   //tc 39
    dut.run(NEW,{10});                                                                  
                                                                   monitor.check_output(monitor.expected_len({10}), dut.run(LEN), "LEN");
  //TC40
    dut.run(NEW,{10,20});                                                                  
                                                                   monitor.check_output(monitor.expected_len({10,20}), dut.run(LEN), "LEN");
    //TC41

    dut.run(NEW,{10,20,30});                                                                  
                                                                   monitor.check_output(monitor.expected_len({10,20,30}), dut.run(LEN), "LEN");
    //TC42
    dut.run(NEW,{10,10,10});                                                                  
                                                                   monitor.check_output(monitor.expected_len({10,20,10}), dut.run(LEN), "LEN");
    //TC43
    dut.run(NEW,{10,20,10,20});                                                                  
                                                                   monitor.check_output(monitor.expected_len({10,20,10,20}), dut.run(LEN), "LEN");
    //TC44
   dut.run(NEW,{});                                                                  
                                                                   monitor.check_output(monitor.expected_len({}), dut.run(LEN), "LEN");//Interesting both 00
                                                                       

                                                                       

                                                                       
    

                                                                       
    
    
    
    
$finish;
    
end
endmodule
  
