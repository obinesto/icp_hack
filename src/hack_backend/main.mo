import Buffer "mo:base/Buffer";
import Error "mo:base/Error";
import Array "mo:base/Array";
import Int "mo:base/Int";

actor Payroll {
  // employee type
  type Employee = {
    name : Text;
    email : Text;
    phone : Nat;
    department : Text;
    jobTitle : Text;
    salary : Nat;
    benefits : Nat;
    taxPercentage : Nat; // takes in tax as a percentage
  };

  // internal employee type with ID
  type InternalEmployee = {
    id : Nat;
    employee : Employee;
  };

  // employee with ID type for UI
  type EmployeeWithID = {
    id : Nat;
    employee : Employee;
  };

  // payroll type
  type Payroll = {
    employees : Buffer.Buffer<InternalEmployee>;
    var totalSalary : Nat;
    var totalBenefits : Nat;
    var totalDeductions : Nat;
    var netSalary : Nat;
  };

  // payroll-calculations type
  type PayrollCalculations = {
    totalSalary : Nat;
    totalBenefits : Nat;
    totalDeductions : Nat;
    netSalary : Nat; // Include net salary
  };

  // Initialize an empty payroll
  var payroll : Payroll = {
    employees = Buffer.Buffer<InternalEmployee>(0);
    var totalSalary = 0;
    var totalBenefits = 0;
    var totalDeductions = 0;
    var netSalary = 0;
  };

  // ID counter for generating unique employee IDs
  var idCounter : Nat = 0;

  // Function to add an employee
  public func addEmployee(employee : Employee) : async () {
    if (employee.salary < 0 or employee.benefits < 0 or employee.taxPercentage < 0 or employee.taxPercentage > 100) {
      throw Error.reject("Invalid employee details");
    };
    let newInternalEmployee = {
      id = idCounter;
      employee = employee;
    };
    payroll.employees.add(newInternalEmployee);
    idCounter += 1; // Increment the ID counter
  };

  // Function to get all employees
  public func getAllEmployees() : async [Employee] {
    var employeesArray : [Employee] = [];
    for (internalEmployee in payroll.employees.vals()) {
      employeesArray := Array.append<Employee>(employeesArray, [internalEmployee.employee]);
    };
    return employeesArray;
  };

  // Function to get all employees with IDs
  public func getAllEmployeesWithID() : async [EmployeeWithID] {
    var employeesArray : [EmployeeWithID] = [];
    for (internalEmployee in payroll.employees.vals()) {
      employeesArray := Array.append<EmployeeWithID>(employeesArray, [{ id = internalEmployee.id; employee = internalEmployee.employee }]);
    };
    return employeesArray;
  };

  // Function to calculate payroll
  public func calculatePayroll() : async PayrollCalculations {
    if (payroll.employees.size() == 0) {
      throw Error.reject("Payroll is empty");
    };

    var totalSalary : Nat = 0;
    var totalBenefits : Nat = 0;
    var totalDeductions : Nat = 0;

    for (internalEmployee in payroll.employees.vals()) {
      let employee = internalEmployee.employee;
      totalSalary += employee.salary;
      totalBenefits += employee.benefits;
      let totalIncome = employee.salary + employee.benefits;
      let tax = (totalIncome * employee.taxPercentage) / 100;
      totalDeductions += tax;
    };

    payroll.totalSalary := totalSalary;
    payroll.totalBenefits := totalBenefits;
    payroll.totalDeductions := totalDeductions;

    // Cast to Int for subtraction and then back to Nat
    let netSalary : Nat = Int.abs((totalSalary + totalBenefits) - totalDeductions);

    let calculations = {
      totalSalary = totalSalary;
      totalBenefits = totalBenefits;
      totalDeductions = totalDeductions;
      netSalary = netSalary; // Include net salary
    };

    return calculations;
  };

  // Function to update employee details
  public func updateEmployee(id : Nat, email : Text, employee : Employee) : async () {
    if (employee.salary < 0 or employee.benefits < 0 or employee.taxPercentage < 0 or employee.taxPercentage > 100) {
      throw Error.reject("Invalid employee details");
    };
    var index : Nat = 0;
    var found = false;
    for (internalEmployee in payroll.employees.vals()) {
      if (internalEmployee.id == id and internalEmployee.employee.email == email) {
        payroll.employees.put(index, { id = id; employee = employee });
        found := true;
        return;
      };
      index += 1;
    };
    if (found == false) {
      throw Error.reject("Employee not found");
    };
  };

  // Function to delete an employee
  public func deleteEmployee(id : Nat, email : Text) : async () {
    var index : Nat = 0;
    var found = false;
    for (internalEmployee in payroll.employees.vals()) {
      if (internalEmployee.id == id and internalEmployee.employee.email == email) {
        ignore payroll.employees.remove(index);
        found := true;
        return;
      };
      index += 1;
    };
    if (found == false) {
      // Employee not found, throw an exception
      throw Error.reject("Employee not found");
    };
  };
};
