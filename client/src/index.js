import React, { Component } from 'react';
import ReactDOM from 'react-dom';
import { Form, Input, Button, InputNumber, Select, Spin, Icon, load,  Alert, Checkbox  } from 'antd';
import Popout from 'react-popout'
import NewWindow from 'react-new-window'
import FetchLoader from 'fetch-loader-react';
import LoadingSpinner from 'react-loader-spinner'
import BounceLoader from 'react-spinners/BounceLoader'
import Img from 'react-image'



import './index.css';
import 'antd/dist/antd.css';

class Chain extends React.Component {
  
  // state = { channels: "A, B, C", organizations: [{name: "x", peers: 100}, {name: "y", peers: 200}] };
   state = { channel: [], organizations: [], opvalue: "", text: "", orgwrite: 0, peerwrite: 0, chnlwrite: 0,orgState: [],  loading: false, data:""};

  onChannelsChange = e => {
    this.setState({channels: e.target.value});
  };
  onTextChange = e => {
    this.setState({text: e.target.value});
  };

  onAddOrganization = () => {
    const arr = [...this.state.organizations];
    const oarr = [...this.state.orgState];
    arr.push({id: arr.length.toString(), name: 'org'+(arr.length+1), peers: 0});
    oarr.push('org'+(oarr.length+1));
    this.setState({organizations: arr});
    this.setState({orgState: oarr});
  };

  onAddChannel = () => {
    const arr = [...this.state.channel];
    arr.push({id: arr.length.toString(), name: 'channel'+(arr.length+1), list: []});
    this.setState({channel: arr});
    
  };

  onRmovOrganization = () => {
    const arr = [...this.state.organizations];
    arr.pop();
    this.setState({organizations: arr});
    const arrorg = [...this.state.orgState];
    arrorg.pop();
    this.setState({orgState: arrorg});
  };

  onRmovChannel = () => {
    const arr = [...this.state.channel];
    arr.pop();
    this.setState({channel: arr});
  };

  createSelectItems() {
     const Option = Select;
     var arr = [...this.state.organizations];
     var per=0;
     let items = []; 
     var k=0;
     var z;
     console.log('length: ' +arr.length); // +id
     if (this.state.chnlwrite == 0) {
     for (var i = 0; i < arr.length; i++) {
          if(arr.length>0){
          console.log('arri: ' + arr[i].peers); // +id
          for (var j=0;j<arr[i].peers; j++){
                z= i+1;       
                k= z*10+j; 
                console.log('k: ' + k); // +id
                items.push(<Select  key={k} value={k}>{'peer'+j+'.'+'org'+z}</Select >); 
         }  
	}
          //here I will be creating my options dynamically based on
          //what props are currently passed to the parent component
     }
}



   else{
 const arr1 = [...this.state.channel];
    if (arr1.length>0){
    var chnl=this.state.chnlwrite-1;
   
     for (var i = 0; i < arr1[chnl].list.length; i++) {
           console.log('arr1[chnl].list: ' +arr1[chnl].list); // +id
          for (var j=0;j<arr[(arr1[chnl].list[i][3])-1].peers; j++){
                z= (arr1[chnl].list[i][3]);       
                k= z*10+j; 
                console.log('k: ' + k); // +id
                items.push(<Select  key={k} value={k}>{'peer'+j+'.'+'org'+z}</Select >); 
 
	}

   }
     }

   }
     return items;
  };  

  onDropdownSelected = value => {
     console.log(`selected ${value}`);
     var x = value%10;
     var y = value/10;
     this.setState({orgwrite: y});
     this.setState({peerwrite: x});
     console.log(`x ${x}`);
     console.log(`y ${y}`);
    //here you will see the current selected value of the select input
  };


  createSelectItemschnl() {
     const Option = Select;
     var arr = [...this.state.channel];
     let items = [<Select  key={0} value={0}>{'channelall'}</Select >]; 
     var k=0;
     var z;
     console.log('length: ' +arr.length); // +id
     for (var i = 0; i < arr.length; i++) {
                z= i+1;       
                items.push(<Select  key={z} value={z}>{'channel' +z}</Select >);   
	}
          //here I will be creating my options dynamically based on
          //what props are currently passed to the parent component
     return items;
  };  

  onDropdownSelectedchnl = value => {
     console.log(`selected ${value}`);
     this.setState({chnlwrite: value});
    //here you will see the current selected value of the select input
  };

  onChangeorganizationName = (e, o) => {
    const arr = [...this.state.organizations];
    console.log('name: ' + e.target.value);
    console.log('id: ' + o.id); // +id
    arr[o.id]={id: o.id, name:e.target.value, peers: o.peers}
    this.setState({organizations: arr});

    // TODO: change the current array (organizations) with the new name
  };

  addPeers = (e, o) => {
    const arr = [...this.state.organizations];
    arr[o.id]={id: o.id, name:o.name, peers: e}
    this.setState({organizations: arr});
  };


  oncannelChange = (e, o) => {
    const arr = [...this.state.channel];
    arr[o.id]={id: o.id, name:o.name, list: e}
    console.log('id: ' + o.id); // +id
    console.log('arr ' + e); // +id
    this.setState({channel : arr});
  };


 addorgwrite = value => {
  this.setState({orgwrite: value});
  console.log('changed', value);
  };
 addpeerwrite = value => {
  this.setState({peerwrite: value});
  console.log('changed', value);
  };

  gotoaskserver = async () => {
   await fetch('http://localhost:8080/api/create', {  
      method: 'POST',  
      headers: {
        'Content-Type': 'application/json',
       },        
        body: JSON.stringify({
         organizations :this.state.organizations,
         channel :this.state.channel,
    })
  })
  .then(function (data) {  
    console.log('Request success: ', data);  
  })  
  .catch(function (error) {  
    console.log('Request failure: ', error);  
  });

  };

  gotobuild = async   () => {
   this.setState({ loading: true, buildsuccess: false, builddata:'' }, async  () => {
   await fetch('http://localhost:8080/api/build', {  
      method: 'POST',  
      headers: {
        'Content-Type': 'application/json',
       },        
        body: JSON.stringify({
         organizations :this.state.organizations,
         channel :this.state.channel,
    })
  }).then( async function (response) {  
        return await response.json();
 
  }).then(   function(json) {
     alert(json.msg);
     console.log(  json.msg);
     return  (json);
     
    // load: false,
     //data: (json.msg),

   // console.log(json);
  }).then( json => this.setState ({
        loading: false,
	buildsuccess: true,
        builddata:  json.msg,
      }));
  });

  };

  gotowrite = () => {
  this.setState({ writeloading: true, writesuccess: false, writedata: '' }, () => {
   fetch('http://localhost:8080/api/write', {  
      method: 'POST',  
      headers: {
        'Content-Type': 'application/json',
       },        
        body: JSON.stringify({
         text :this.state.text,
         channels :this.state.channels,
         orgwrite: this.state.orgwrite, 
         peerwrite: this.state.peerwrite,
         chnlwrite: this.state.chnlwrite,
    })
  })
  .then(function (response) {  
        return response.json();
 
  })  
  .then(function(json) {
     //alert(json.msg);
     return (json);
     
    // load: false,
     //data: (json.msg),

   // console.log(json);
  })   .then(result  => this.setState({
        writeloading: false,
        writesuccess: true,
        writedata: result.msg,
      }));
  });

  };

  gotoread = () => {
     this.setState({ readloading: true }, () => {
     fetch('http://localhost:8080/api/read', {  
      method: 'POST',  
      headers: {
        'Content-Type': 'application/json',
       },        
        body: JSON.stringify({
         channels :this.state.channels,
         orgwrite: this.state.orgwrite, 
         peerwrite: this.state.peerwrite,
    })
  })
  .then(function (response) {  
        return  response.json();
  })  
  .then(function(json) {
       var i,line;
       line='';

       var myWindow = window.open('', '', "width=500, height=300");
       for(i=0;i<json.msg.length;i++){
          if(json.msg[i] != '\n'){
             line+=json.msg[i];
          }
          else{
                          console.log(line);
                   myWindow.document.write("<p>" + line + "</p>");
                   line='';
          }
        
       }
        //myWindow.blur();

      // alert(json.msg);
    //console.log(json);
  })   .then(json => this.setState({
        readloading: false,
      }));
  });

  };


  gotodown = () => {
   fetch('http://localhost:8080/api/down', {  
      method: 'POST',  
      headers: {
        'Content-Type': 'application/json',
       },        
        body: JSON.stringify({
         text :this.state.text,
         channels :this.state.channels,
    })
  })
  .then(function (response) {  
        return response.json();
 
  })  
  .then(function(json) {
    alert(json.msg);
    console.log(json);
  });

  };

  onChange1(value) {
  console.log(`selected ${value}`)
  };

  onBlur() {
  console.log('blur')
  };

  onFocus() {
  console.log('focus')
  };

  onSearch(val) {
  console.log('search:', val)
  };
   
  
  render() {
    let Img = require('react-image');
    const { writedata, loading,writeloading, readloading, writesuccess,buildsuccess ,builddata, orgState } = this.state;
    const Option = Select;
    const CheckboxGroup = Checkbox.Group;
   const plainOptions = ['Apple', 'Pear', 'Orange'];
   const checkedList = [];

    return (
        <div>
        <div>
          <Img src="https://www.cryptoninjas.net/wp-content/uploads/2017/12/blockchaincom.png" width="600" height="250" />

          <div>PRESS + TO ADD ORG</div>
          <Button type="primary" shape="circle" icon="plus" onClick={this.onAddOrganization} />
          <div>Organizations</div>
          {this.state.organizations.map(o => {
            return <div key={o.id}>
              <Input placeholder='Organization Name' value={o.name} onChange={(e) => this.onChangeorganizationName(e, o)}/>
              <InputNumber value={o.peers} onChange={(e) => this.addPeers(e, o)} />

            </div>
          })}
        <div>
          <Button type="primary" shape="circle" icon="minus" onClick={this.onRmovOrganization} />
        </div>

         <div>PRESS + TO ADD  new channels (by default you have the public channel with all the organizations)</div>
          <Button type="primary" shape="circle" icon="plus" onClick={this.onAddChannel} />
          <div>Channel</div>
          {this.state.channel.map(o => {
            return <div key={o.id}>
              <Input placeholder='channel Name' value={o.name} />
       <CheckboxGroup
          options={orgState}
          value={o.list} onChange={(e) => this.oncannelChange(e, o) }
        />
            </div>
          })}
        <div>
          <Button type="primary" shape="circle" icon="minus" onClick={this.onRmovChannel} />
        </div>

        </div>
     

      
        <div>
         <Button type="primary" onClick={this.gotobuild} >Set configuration and Build the nerwork</Button>
        </div>
         {loading ? <Spin />  : buildsuccess ? <Alert message={builddata} type="info"  />   : <div></div> }

          <Form.Item>
          <div>write file line </div>

          <Input placeholder='write file line'
            value={this.state.text}
            onChange={this.onTextChange}/>
          <div>      peers organization         </div>
	 <Select  onChange={this.onDropdownSelectedchnl}>
	       {this.createSelectItemschnl()}
	 </Select>
	 <Select  onChange={this.onDropdownSelected}>
	       {this.createSelectItems()}
	 </Select>
            {writeloading ? <Spin /> : writesuccess ? <Alert message={writedata} type="info"  />   : <div></div> }
         <Button type="primary"  onClick={this.gotowrite} >submit write</Button>
        </Form.Item>
        <div>

        </div>

      <div> press here to read the chain   </div>
          <div>      peers organization         </div>
	 <Select  onChange={this.onDropdownSelectedchnl}>
	       {this.createSelectItemschnl()}
	 </Select>
	 <Select  onChange={this.onDropdownSelected}>
	       {this.createSelectItems()}
	 </Select>
	   {readloading ? <Spin /> : <div></div> }
         <Button type="primary" onClick={this.gotoread} >read chain</Button>
       
        <div>

        </div>


          <div>press here for down the network</div>
      
        <div>
         <Button type="primary" onClick={this.gotodown} >down the network</Button>
        </div>
            <Img src="https://www.hyperledger.org/wp-content/uploads/2018/10/Hyperledger-Fabric.png" width="200" height="90" />
            <Img src="https://bilberry.io/img/partners/nokiabelllabs.png" width="350" height="250" />
   </div>

    );
  }
}

// ========================================

ReactDOM.render(
  <Chain />,
  document.getElementById('root')
);












