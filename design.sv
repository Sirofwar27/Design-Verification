// Code your design here
// Code your design here
class Node;
  bit[0:7] data;
  Node _next;
  
  function new(bit[0:7] data, Node _next=null);
  	this.data = data;
    this._next = _next;
  endfunction
endclass

typedef bit[0:7] list_q[$];

class linked_list;
  Node head = null;
  
  function new(list_q data);
    Node current, next;
    foreach(data[i]) begin
      if(i == 0) begin
        this.head = new(data[0]);
        current = head;
      end else begin
        next = new(data[i]);
        current._next = next;
        current = next;
      end
    end
  endfunction
  
  function list_q traverse();
    list_q list;
    Node current = this.head;
    while(current != null) begin
      list.push_back(current.data);
      current = current._next;
    end
    return list;
  endfunction
  
  function list_q find(int data);
    list_q list;
    Node current = this.head;
    int idx = 0;
    while(current != null) begin
      if(current.data == data) begin
        list.push_back(idx);
      end
      current = current._next;
      idx += 1;
    end
    if (list.size == 0) return {-1};
    return list;
  endfunction
  
  function list_q insert(bit[0:7] prev_data, bit[0:7] next_data);
    Node current = this.head;
    Node prev = null;
    Node next = new(next_data);
    
    do begin
      if(current.data == prev_data) begin
        next._next = current._next;
        current._next = next;
        break;
      end
      prev = current;
      current = current._next;
    end while(current != null);
    return traverse;	
  endfunction
  
  function list_q delete(bit[0:7] data);
        
    Node current = this.head._next;
    Node prev = this.head;
    
    if (this.head.data == data) begin
      this.head = this.head._next;
      return;
    end
    
    while(current != null) begin
      if (current.data == data) begin
        prev._next = current._next;
      end
      prev = current;
      current = current._next;
    end
    return traverse;
  endfunction
  
  function list_q len();
    Node current = this.head;
    int length = 1;
    
    if(current == null) begin
      length = 0;
    end
    
    while(current != null) begin
      length += 1;
      current = current._next;
    end
    return {length};
  endfunction
  
  function list_q reverse();
    Node items[$];
    Node current = head;
    
    while(current != null) begin
      items.push_front(current);
      current = current._next;
    end
    
    head = items.pop_front();
    items.push_back(null);
    current = head;
    
    while(items[0] != null) begin
      current._next = items.pop_front();
      current = current._next;
    end
    
    current._next = null;
    return traverse;
  endfunction
  
  
endclass

typedef enum bit[0:2] {NEW=0,TRAVERSE=1,FIND=2,INSERT=3,DELETE=4,LEN=5,REVERSE=6} opcode_u;

class DUT;
  linked_list list;
  
  function new();
    list = new({});
  endfunction
  
  function list_q run(opcode_u op, list_q data = {});
      case(op)
        NEW: begin 
          list = new(data);
          return list.traverse;
        end
        TRAVERSE: return list.traverse;
        FIND: return list.find(data[0]);
        INSERT: return list.insert(data[0], data[1]);
        DELETE: return list.delete(data[0]);
        LEN: return list.len();
        REVERSE: return list.reverse();
        default: return {};
      endcase
    endfunction
endclass